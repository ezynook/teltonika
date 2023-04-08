#!/bin/sh

#เช็คว่ามีไฟล์แล้วหรือไม่หากมีให้ลบก่อน
if [ -n "$(ls /bin/ | grep ipsec_check)" ]; then
	rm -f /bin/ipsec_check.sh
fi
if [ -n "$(ls /bin/ | grep chkservice)" ]; then
	rm -f /bin/chkservice.sh
fi
if [ -n "$(ls /bin/ | grep uptime)" ]; then
	rm -f /bin/uptime.sh
fi
if [ -n "$(ls /bin/ | grep script_retry)" ]; then
  rm -f /bin/script_retry.sh
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
  iptables -F
  iptables -X
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables-save
  echo "$TODAY -> Reboot router because IPSec disconnected" >> /var/log/da.log
fi
#ล้าง Memory
sync; echo 3 > /proc/sys/vm/drop_caches' >> /bin/chkservice.sh
echo "$TODAY -> Create ChkService Successfully"

touch /bin/ipsec_check.sh && chmod 775 /bin/ipsec_check.sh
echo '#!/bin/sh
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
echo "Update Available Package"
opkg update
/bin/ipsec_check.sh
/bin/chkservice.sh
/bin/script_retry.sh
/bin/uptime.sh
#----------Developed by Pasit Y. 2023-04-07--------------
