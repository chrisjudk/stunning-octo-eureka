#!/bin/bash
NOW=$(date +'%Y-%m-%d')
Telnetlogin=$(sed -n '2,2p; 3q' ./credentials)
Telnetpassword=$(sed -n '4,4p; 5q' ./credentials)
cd "/root/"
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
echo 'apt-get update' >> /var/local/log/apt/$NOW.log
apt-get -y update >> /var/local/log/apt/$NOW.log
echo 'apt-get dist-upgrade' >> /var/local/log/apt/$NOW.log
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade >> /var/local/log/apt/$NOW.log
echo 'apt-get autoclean' >> /var/local/log/apt/$NOW.log
apt-get -y autoclean >> /var/local/log/apt/$NOW.log
echo 'apt-get autoremove' >> /var/local/log/apt/$NOW.log
apt-get -y autoremove >> /var/local/log/apt/$NOW.log
#CHECKRESTART=$(/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file')
#$CHECKRESTART
/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file'
if [ $? -eq 0 ]
then
  echo $NOW: Update complete, no restart required >> /var/local/log/update.log
else
  echo $NOW: Update complete, restart required >> /var/local/log/update.log
  ./tstelnet.sh $Telnetlogin $Telnetpassword
  sudo -u ts3server /home/ts3server/ts3server stop
  /sbin/shutdown -r now
fi
