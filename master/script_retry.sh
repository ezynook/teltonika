#!/bin/sh

#-----------------------------------------------------
#Reserved Checker Every Minute (Slave from chkservice)
#-----------------------------------------------------

TODAY=`date +%d-%m-%Y:%H-%M-%S`

echo "-------------------Check Sim Status-------------------"
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
#
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
#
echo "-------------------Check VPN IPSec (Tier 2 -C1)-------------------"
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
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
