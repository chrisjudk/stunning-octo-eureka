#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get autoclean
apt-get autoremove -y
NOW=$(date +'%Y-%m-%d')
#CHECKRESTART=$(/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file')
#$CHECKRESTART
/usr/sbin/checkrestart -v | grep -q 'Found 0 processes using old versions of upgraded file'
if [ $? -eq 0 ]
then
  echo $NOW: Update complete, no restart required >> /var/local/log/update.log
else
  echo $NOW: Update complete, restart required >> /var/local/log/update.log && /usr/local/bin/teamspeak/tstelnet1.sh && /etc/init.d/teamspeak3 stop && /sbin/shutdown -r now
fi
