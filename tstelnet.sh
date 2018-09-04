#!/usr/bin/expect
# Set login as argument 0
set Login [lindex $argv 0]
# Set password as argument 1
set Password [lindex $argv 1]
#If it all goes pear shaped the script will timeout after 20 seconds.
set timeout 20

#This spawns the telnet program and connects it to the variable name
spawn telnet 127.0.0.1 10011 
#The script sends the user variable
sleep 3
send "login $Login $Password\r"
send "use sid=1\r"
send "logadd loglevel=3 logmsg=Ubuntu\\sServer\\sLogin"
send "\r"
send "logadd loglevel=3 logmsg=Ubuntu\\sServer\\sRestart"
send "\r"
send "gm msg=Server\\sis\\sshutting\\sdown..."
send "\r"
sleep 30
#This hands control of the keyboard over to you (Nice expect feature!)
#interact
