#!/bin/sh

TODAY=`date +%d-%m-%Y:%H-%M-%S`
echo "-------------------Check Sim Status-------------------"
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
echo "-------------------Check VPN Status (Tier 1 -C3)-------------------"
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
    echo "$TODAY -> Reboot router because IPSec disconnected" >> /var/log/da.log
else
    echo "$TODAY -> Service IPSec is Normal"
    echo "Last check at: $TODAY -> Service IPSec is Normal" >> /var/log/da.log
fi
echo "-------------------Check Signal Status-------------------"
SIGNAL1=$(gsmctl -q)
VALUE1="-100"

if [ "$SIGNAL1" -le "$VALUE1" ]; then
        echo "Loss Signal Restart Device at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Bad = ${SIGNAL1}"
        reboot #init 6
else
        echo "Signal is Normal at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Good = ${SIGNAL1}"
fi
echo "-------------------Check VPN IPSec (Tier 2 -C1)-------------------"
ping -c3 10.0.255.1 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
  echo "$TODAY -> Service IPSec is Normal"
  echo "Last check at: $TODAY -> Service IPSec is Normal" >> /var/log/da.log
else
  /etc/init.d/ipsec restart
  iptables -F
  iptables -X
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables-save
  echo "$TODAY -> Reboot router because IPSec disconnected" >> /var/log/da.log
fi