#!/bin/sh

#--------------------------
#IPSec Check Every Minute
#--------------------------

TODAY=`date +%d-%m-%Y:%H-%M-%S`

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
#
ipsec_status=$(ipsec status)

if echo "$ipsec_status" | grep -q 'ESTABLISHED'; then
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
