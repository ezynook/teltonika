#!/bin/sh

#----------------------------------------------
#IPSec Check Every Minute For RUT200 New Series
#----------------------------------------------
ipsec_check(){
    /etc/init.d/ipsec restart >/dev/null 2>&1
    iptables -F >/dev/null 2>&1
    iptables -X >/dev/null 2>&1
    iptables -P INPUT ACCEPT >/dev/null 2>&1
    iptables -P FORWARD ACCEPT >/dev/null 2>&1
    iptables -P OUTPUT ACCEPT >/dev/null 2>&1
    iptables-save >/dev/null 2>&1
}
TODAY=`date +%d-%m-%Y:%H-%M-%S`
#
echo "+-Check Sim Status (Connected)-+"
if [ -z "$(gsmctl -j | grep Connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    sleep 3
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
#
echo "+-Checking Signal Status (Tier 1 -3C)-+"
SIGNAL=`gsmctl -q | grep RSSI | awk '{print $2}' | cut -f2 -d"-"`
VALUE="90"

if [ "$SIGNAL" -ge "$VALUE" ]; then
        echo "Loss Signal Restart Device at: ${SIGNAL}"
        S_SG="Signal 4G is Bad = ${SIGNAL}"
        reboot
else
        echo "Signal is Normal at: ${SIGNAL}"
        S_SG="Signal 4G is Good = ${SIGNAL}"
fi
#
echo "+-Ping to HQ-+"
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
ret=$?
if [ $ret -ne 0 ]; then
        ipsec_check
        echo "$TODAY -> Reboot service IPSec because IPSec disconnected" >> /var/log/da.log
else
        echo "$TODAY -> Service IPSec is Normal"
        echo "Last check at: $TODAY -> Service IPSec is Normal" >> /var/log/da.log
fi
#
echo "+-Ping Check Outgoing (16 Bytes Package)-+"
if ! ping -c 5 -W 1 -s 16 google.com >/dev/null 2>&1; then
  ipsec_check
else
  echo "Last check Outgoing at: $TODAY -> Normal" >> /var/log/da.log
fi

