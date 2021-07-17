#!/bin/bash
NOW=$(date +'%Y-%m-%d') # Get current date and put in YYYY-MM-DD format
cd "${0%/*}" # Changed directory to the directory of this file

# Set specific variables used for apt-get
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Updates
printf "\n$NOW: Begin\n" > >(tee -a /var/local/log/error.log)
echo 'NOTE: All apt errors will be forwarded to /var/local/log/error.log' > >(tee -a /var/local/log/apt/$NOW.log)
echo '----------[apt-get update]--------------------' > >(tee -a /var/local/log/apt/$NOW.log)
apt-get -y update > >(tee -a /var/local/log/apt/$NOW.log) 2> >(tee -a /var/local/log/error.log >&2) #Get updates and write output to log file with current date as title
echo '----------[apt-get dist-upgrade]--------------------' > >(tee -a /var/local/log/apt/$NOW.log)
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade > >(tee -a /var/local/log/apt/$NOW.log) 2> >(tee -a /var/local/log/error.log >&2) #Install updates and write output to log file
echo '----------[apt-get autoclean]--------------------' > >(tee -a /var/local/log/apt/$NOW.log)
apt-get -y autoclean > >(tee -a /var/local/log/apt/$NOW.log) 2> >(tee -a /var/local/log/error.log) #Autoclean and output to log
echo '----------[apt-get autoremove]--------------------' > >(tee -a /var/local/log/apt/$NOW.log)
apt-get -y autoremove > >(tee -a /var/local/log/apt/$NOW.log) 2> >(tee -a /var/local/log/error.log) #Autoremove and output to log
printf "\n$NOW: End\n" > >(tee -a /var/local/log/error.log)

#Check if Restart is required
/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file'
if [ $? -eq 0 ]
then
  printf "\n$NOW: Update complete, no restart required\n" > >(tee -a /var/local/log/update.log)
else
  printf "\n$NOW: Update complete, restart required\n" > >(tee -a /var/local/log/update.log)
  /sbin/shutdown -r now # Shutdown system
fi
