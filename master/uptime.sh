#!/bin/sh

#-----------------------------
#Uptime Sim Status Date Check
#-----------------------------
TODAY=`date +%d-%m-%Y:%H-%M-%S`

echo "-----------------Checking Signal Uptime By Day-------------------"
DATENOW=$(date +'%Y-%m-%d')
UPTIME_NOW=$(gsmctl --modemtime 2 | awk '{print $1}')

if [ "$UPTIME_NOW" == "$DATENOW" ]; then
    echo "$TODAY -> State Update Check by Date Successfully" >> /var/log/da.log
else
    echo "$TODAY -> State Update Check by Date Failure" >> /var/log/da.log
    reboot
fi
exit 0
