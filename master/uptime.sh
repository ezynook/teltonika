#!/bin/sh

echo "Checking Signal Uptime Logdate equal date now..."
DATENOW=$(date +'%Y-%m-%d')                          
UPTIME_NOW=$(gsmctl --modemtime 2 | awk '{print $1}')

if [ "$UPTIME_NOW" == "$DATENOW" ]; then                                       
    echo "$TODAY -> State Update Check by Date Successfully" >> /var/log/da.log
else                                                                      
    echo "$TODAY -> State Update Check by Date Failure" >> /var/log/da.log
    reboot
fi
