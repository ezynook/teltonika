#!/bin/sh

checkipsec=`ls /bin/ | grep ipsec_check`
checkchkservice=`ls /bin/ | grep chkservice.sh`
checkuptime=`ls /bin/ | grep uptime.sh`
#เช็คว่ามีไฟล์แล้วหรือไม่หากมีให้ลบก่อน
if [ -n "$checkipsec" ]; then
	rm -f /bin/ipsec_check.sh
fi
if [ -n "$checkchkservice" ]; then
	rm -f /bin/chkservice.sh
fi
if [ -n "$checkuptime" ]; then
	rm -f /bin/uptime.sh
fi

echo "*/5 * * * * /sbin/ping_reboot 1 8.8.8.8 2 56 5 2 0 cfg01c21d" > /etc/crontabs/root
echo "0 * * * * /etc/init.d/rut_fota start" >> /etc/crontabs/root

mkdir -p /var/log/
touch /var/log/da.log
touch /bin/chkservice.sh && chmod 775 /bin/chkservice.sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
#เริ่มเขียนโค๊ด chkservice.sh
echo '#!/bin/sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
TOKEN="JFJyi78b88GS71LEOXps5033VvAHoswaDGHlnK8jY8q" #Line Toey Tech.
#เช็คว่ามีสัญญาณมาจากผู้ให้บริการหรือไม่
if [ -z "$(gsmctl -j | grep connected)" ]; then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi
#เช็ค VPN IPSec
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
ret=$?
if [ $ret -ne 0 ]; then
    /etc/init.d/ipsec restart
    #/etc/init.d/dnsmasq reload
    #/etc/init.d/network reload
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
#เช็คค่าสัญญาณ (dbs)
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
#เช็คค่าสัญญาณ Tier 2
ping -c3 10.0.255.1 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
  echo "$TODAY -> Service IPSec is Normal"
  echo "Last check at: $TODAY -> Service IPSec is Normal" >> /var/log/da.log
else
  /etc/init.d/ipsec restart
  #/etc/init.d/dnsmasq reload
  #/etc/init.d/network reload
  iptables -F
  iptables -X
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables-save
  echo "$TODAY -> Reboot router because IPSec disconnected" >> /var/log/da.log
fi
#ล้าง Memory
sync; echo 3 > /proc/sys/vm/drop_caches 

#Script Check state by Pasit
newline=$'"'\n'"'
title="[Teltonika Report]"
mICCID="Sim No.: "
ICCID=`gsmctl -J`
mCarr="Carrier: "
Carr=`gsmctl -o`
IPm="IP Private: "
IP2m="IP Public: "
IP2=`gsmctl --ip wwan0`
IP=`gsmctl --ip br-lan`
Statusm="Status: "
Status=`gsmctl -j`
devicem="Device No.: "
device=`gsmctl -a`
sitem="Customer: "
site=`cat /etc/ipsec.conf | grep -m 1 "leftid=" | cut -c9-0`
site2=`cat /etc/ipsec.conf | grep -m 1 "conn" | cut -c5-0`
sitecus="${site} / ${site2}"
fwm="Firmware V. "
fw=`cat /etc/version | cut -c10-0`
dates="Last check: $TODAY"
TOTAL="$newline $title $newline $mICCID $ICCID $newline $mCarr $Carr $newline $IPm $IP $newline $IP2m $IP2 $newline $Statusm $Status $newline $S_SG $newline $devicem $device $newline $sitem $sitecus $newline $fwm $fw $newline $dates"
curl -X POST -H "Authorization: Bearer $TOKEN" -F "message=$TOTAL" https://notify-api.line.me/api/notify' >> /bin/chkservice.sh
echo "$TODAY -> Create ChkService Successfully"

touch /bin/ipsec_check.sh && chmod 775 /bin/ipsec_check.sh
echo '#!/bin/sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
ret=$?
if [ $ret -ne 0 ]; then
        /etc/init.d/ipsec restart
        #/etc/init.d/dnsmasq reload
        #/etc/init.d/network reload
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
fi' >> /bin/ipsec_check.sh
echo "$TODAY -> Create IPSec Successfully"
cd /bin/; curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/uptime.sh; chmod +x /bin/uptime.sh
cd /bin/; curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/script_retry.sh; chmod +x /bin/script_retry.sh

echo "0 9 * * * /bin/chkservice.sh" >> /etc/crontabs/root
echo "* * * * * /bin/script_retry.sh" >> /etc/crontabs/root
echo "* * * * * /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "*/15 * * * * /bin/uptime.sh" >> /etc/crontabs/root
echo "59 23 * * * sync; echo 3 > /proc/sys/vm/drop_caches " >> /etc/crontabs/root
echo "@reboot /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "$TODAY -> Create Cronjob Successfully"
echo "Add Resolve DNS"
echo "nameserver 8.8.8.8" >> /tmp/resolv.conf.auto
echo "Crontab Task Restarting and Enable to Spool"
/etc/init.d/cron enable
/etc/init.d/cron restart
#/etc/init.d/ipsec restart
#/etc/init.d/dnsmasq reload
#/etc/init.d/network reload
echo "Update Available Package"
opkg update
/bin/ipsec_check.sh
/bin/chkservice.sh
/bin/script_retry.sh
/bin/uptime.sh
#----------Developed by Pasit Y. 2023-04-07--------------
