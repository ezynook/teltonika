#!/bin/sh
#------------------------------
#Script Launcher Main Code
#------------------------------
echo "
----------------------------
Teltonika Monitoring Script
Author: Engineer NW & TC
----------------------------
-> Please wait ......
"
sleep 5
#
TODAY=`date +%d-%m-%Y:%H-%M-%S`
#
if [ "$1" == '-append' ]; then
	echo '
newline=$'"'\n'"'
title="[Teltonika Report]"
mICCID="Sim No.: "
ICCID=`gsmctl -J`
mCarr="Carrier: "
Carr=`gsmctl -o`
high_signal="Signal Status: $(gsmctl -t)"
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
TOTAL="$newline $title $newline $mICCID $ICCID $newline $mCarr $Carr $newline $IPm $IP $newline $IP2m $IP2 $newline $Statusm $Status $newline $S_SG $newline $high_signal $newline $devicem $device $newline $sitem $sitecus $newline $fwm $fw $newline $dates"
curl -X POST -H "Authorization: Bearer $TOKEN" -F "message=$TOTAL" https://notify-api.line.me/api/notify' >> /bin/chkservice.sh
echo "Append Sendline to Existing Script..."
exit 1
fi
#
echo "Check file all ready Exists...!"
if [ -n "$(ls /bin/ | grep ipsec_check)" ]; then
	rm -f /bin/ipsec_check.sh
fi
if [ -n "$(ls /bin/ | grep chkservice.sh)" ]; then
	rm -f /bin/chkservice.sh
fi
#
echo "Create Log Directory..."
mkdir -p /var/log/
touch /var/log/da.log
#
echo "Get Script from github server..."
cd /bin/
curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/master/ipsec_check.sh >/dev/null 2>&1
curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/master/chkservice.sh >/dev/null 2>&1
chmod +x /bin/ipsec_check.sh
chmod +x /bin/chkservice.sh
#
echo "Writing Crontab Scheduler..."
echo "0 * * * * /sbin/ping_reboot 1 8.8.8.8 2 56 5 2 0 cfg01c21d" > /etc/crontabs/root
echo "0 * * * * /etc/init.d/rut_fota start" >> /etc/crontabs/root
echo "0 9 * * * /bin/chkservice.sh" >> /etc/crontabs/root
echo "* * * * * /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "59 23 * * * sync; echo 3 > /proc/sys/vm/drop_caches " >> /etc/crontabs/root
echo "@reboot /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "$TODAY -> Create Cronjob Successfully..."
echo "Crontab Task Restarting and Enable to Spool..."
/etc/init.d/cron enable
/etc/init.d/cron restart
#
echo "Assign DNS to network WWAN0"
CHECKLINE=`cat /etc/config/network | grep -n "config interface 'ppp'"| awk '{print $1}' | cut -f1 -d ":"`
PLUSLINE1=$((CHECKLINE+1))
PLUSLINE2=$((CHECKLINE+2))
PLUSLINE3=$((CHECKLINE+3))
sed -i "s/option peerdns '1'/option peerdns '0'/g" /etc/config/network
if [ -z "$(cat /etc/config/network | grep 'option peerdns')" ]; then
	sed -i "${PLUSLINE1}i ${nl}" /etc/config/network
	sed -i -E "${PLUSLINE}i \\\toption peerdns '0'" /etc/config/network
fi
sed -i "${PLUSLINE2}i ${nl}" /etc/config/network
sed -i -E "${PLUSLINE2}i \\\tlist dns '8.8.8.8'" /etc/config/network
sed -i "${PLUSLINE3}i ${nl}" /etc/config/network
sed -i -E "${PLUSLINE3}i \\\tlist dns '8.8.4.4'" /etc/config/network
/etc/init.d/network reload
#
echo "Check and Add Resolve DNS..."
echo > /tmp/resolv.conf.auto
echo "nameserver 8.8.8.8" > /tmp/resolv.conf.auto
#
echo "Add Logon Script profile..."
echo "
/bin/ipsec_check.sh" >> /etc/profile
#
echo "Update available package and reloading service has Up-to-Date please wait..."
opkg update >/dev/null 2>&1
#
if [ -z "$1" ]; then
	echo '
newline=$'"'\n'"'
title="[Teltonika Report]"
mICCID="Sim No.: "
ICCID=`gsmctl -J`
mCarr="Carrier: "
Carr=`gsmctl -o`
high_signal="Signal Status: $(gsmctl -t)"
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
TOTAL="$newline $title $newline $mICCID $ICCID $newline $mCarr $Carr $newline $IPm $IP $newline $IP2m $IP2 $newline $Statusm $Status $newline $S_SG $newline $high_signal $newline $devicem $device $newline $sitem $sitecus $newline $fwm $fw $newline $dates"
curl -X POST -H "Authorization: Bearer $TOKEN" -F "message=$TOTAL" https://notify-api.line.me/api/notify' >> /bin/chkservice.sh
fi
#
echo "Please wait Starting All Service..."
#
/bin/ipsec_check.sh 
/bin/chkservice.sh 
source /etc/profile
