#!/bin/sh

TODAY=`date +%d-%m-%Y:%H-%M-%S`

echo "Check Sim signal status..."
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi

echo "Check VPN Status (Tier 1 -C3)..."
ping -c3 10.0.255.1 > /dev/null 2>&1
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

echo "Check Sim Signal Level Value Status..."
SIGNAL1=$(gsmctl -q)
VALUE1="-90"

if [ "$SIGNAL1" -ge "$VALUE1" ]; then
        echo "Loss Signal Restart Device at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Bad = ${SIGNAL1}"
        reboot #init 6
else
        echo "Signal is Normal at: ${TODAY}" >> /var/log/check_signal.log
        S_SG="Signal 4G is Good = ${SIGNAL1}"
fi

echo "${BGreen} Check VPN IPSec (Tier 2 -C1)..."
ping -c1 10.0.255.1 > /dev/null 2>&1
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

echo "Check to connecting to public Google DNS..."
ping -c5 8.8.8.8 > /dev/null 2>&1
google_dns=$?

if [ $google_dns -ne 0 ]; then
        /etc/init.d/ipsec restart
        /etc/init.d/dnsmasq restart
        /etc/init.d/network restart
        iptables -F
        iptables -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables-save
        echo "$TODAY -> Reboot router because connecting to google dns disconnected" >> /var/log/da.log
else
        echo "$TODAY -> Service DNS is Normal"
        echo "Last check at: $TODAY -> Service DNS is Normal" >> /var/log/da.log
fi
