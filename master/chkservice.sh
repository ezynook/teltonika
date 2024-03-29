#!/bin/sh

#-----------------------------------------
#Check All Service Run Every at: 09:00 AM
#-----------------------------------------
ipsec_check(){
    /etc/init.d/ipsec restart >/dev/null 2>&1
    iptables -F >/dev/null 2>&1
    iptables -X >/dev/null 2>&1
    iptables -P INPUT ACCEPT >/dev/null 2>&1
    iptables -P FORWARD ACCEPT >/dev/null 2>&1
    iptables -P OUTPUT ACCEPT >/dev/null 2>&1
    iptables-save >/dev/null 2>&1
}
#
TODAY=`date +%d-%m-%Y %H:%M:%S`
#Line Token (Toey Account)
TOKEN="JFJyi78b88GS71LEOXps5033VvAHoswaDGHlnK8jY8q"
#
echo "+-Checking file all ready exists-+"
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
#
echo "+-Checking Signal Status (Tier 1 -3C)-+"
SIGNAL1=$(gsmctl -q)
VALUE1="-90"

if [ "$SIGNAL1" -ge "$VALUE1" ]; then
        echo "Loss Signal Restart Device at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Bad = ${SIGNAL1}"
        reboot
else
        echo "Signal is Normal at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Good = ${SIGNAL1}"
fi
#
echo "+-Ping to HQ-+"
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
ret=$?
if [ $ret -ne 0 ]; then
        /etc/init.d/ipsec restart
        iptables -F
        iptables -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables-save
        echo "$TODAY -> Reboot service IPSec because IPSec disconnected" >> /var/log/da.log
else
        echo "$TODAY -> Service IPSec is Normal"
        echo "Last check at: $TODAY -> Service IPSec is Normal" >> /var/log/da.log
fi
#Check Outgoing

if ! ping -c 5 -W 1 -s 16 google.com >/dev/null 2>&1; then
  ipsec_check
else
  echo "Last check Outgoing at: $TODAY -> Normal" >> /var/log/da.log
fi
#
echo "+-Ping Check Outgoing (16 Bytes Package)-+"
sync; echo 3 > /proc/sys/vm/drop_caches
#Send Line
newline=$'\n'
title="[Teltonika Report]"
mICCID="Sim No.: "
ICCID=$(gsmctl -J)
mCarr="Carrier: "
Carr=$(gsmctl -o)
high_signal="Signal Status: $(gsmctl -t)"
IPm="IP Private: "
IP2m="IP Public: "
IP2=$(gsmctl --ip wwan0)
IP=$(gsmctl --ip br-lan)
Statusm="Status: "
Status=$(gsmctl -j)
devicem="Device No.: "
device=$(gsmctl -a)
sitem="Customer: "
site=$(cat /etc/ipsec.conf | grep -m 1 "leftid=" | cut -c9-0)
site2=$(cat /etc/ipsec.conf | grep -m 1 "conn" | cut -c5-0)
sitecus="${site} / ${site2}"
fwm="Firmware V. "
fw=$(cat /etc/version | cut -c10-0)
TODAY=$(date +"%Y-%m-%d")
dates="Last check: $TODAY"
TOTAL="$newline $title $newline $mICCID $ICCID $newline $mCarr $Carr $newline $IPm $IP $newline $IP2m $IP2 $newline $Statusm $Status $newline $high_signal $newline $devicem $device $newline $sitem $sitecus $newline $fwm $fw $newline $dates"

curl -X POST -H "Authorization: Bearer $TOKEN" -F "message=$TOTAL" https://notify-api.line.me/api/notify
