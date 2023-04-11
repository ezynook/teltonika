#!/bin/sh

#-----------------------------------------
#Check All Service Run Every at: 09:00 AM
#-----------------------------------------

TODAY=`date +%d-%m-%Y:%H-%M-%S`

TOKEN="JFJyi78b88GS71LEOXps5033VvAHoswaDGHlnK8jY8q" #Line Token (Toey Account)
echo "------------Checking file all ready exists---------------------"
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
#
echo "------------------Checking Signal Status (Tier 1 -3C)--------------------"
SIGNAL1=$(gsmctl -q)
VALUE1="-100"

if [ "$SIGNAL1" -le "$VALUE1" ]; then
        echo "Loss Signal Restart Device at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Bad = ${SIGNAL1}"
        reboot
else
        echo "Signal is Normal at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Good = ${SIGNAL1}"
fi
#
sync; echo 3 > /proc/sys/vm/drop_caches
