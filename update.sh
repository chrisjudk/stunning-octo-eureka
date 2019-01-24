#!/bin/bash
NOW=$(date +'%Y-%m-%d') # Get current date and put in YYYY-MM-DD format
cd "${0%/*}" # Changed directory to the directory of this file

# Read telnet credentials from file
telnetLogin=$(sed -n '2,2p; 3q' ./credentials)
telnetPassword=$(sed -n '4,4p; 5q' ./credentials)

# Set specific variables used for apt-get
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Updates
echo '----------[apt-get update]--------------------' >> /var/local/log/apt/$NOW.log
apt-get -y update >> /var/local/log/apt/$NOW.log # Get updates and write output to log file with current date as title 
echo '----------[apt-get dist-upgrade]--------------------' >> /var/local/log/apt/$NOW.log 
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade >> /var/local/log/apt/$NOW.log # Install updates and write output to log file
echo '----------[apt-get autoclean]--------------------' >> /var/local/log/apt/$NOW.log 
apt-get -y autoclean >> /var/local/log/apt/$NOW.log # Autoclean and output to log
echo '----------[apt-get autoremove]--------------------' >> /var/local/log/apt/$NOW.log
apt-get -y autoremove >> /var/local/log/apt/$NOW.log # Autoremove and output to log

#Check if Restart is required
/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file'
if [ $? -eq 0 ]
then
  echo $NOW: Update complete, no restart required >> /var/local/log/update.log
else
  echo $NOW: Update complete, restart required >> /var/local/log/update.log
  ./tstelnet.sh $telnetLogin $telnetPassword # Run telnet to send global message to TS server letting everyone know that the server is about to shutdown
  sudo -u ts3server /home/ts3server/ts3server stop # Stop the teamspeak server
  /sbin/shutdown -r now # Shutdown system
fi
