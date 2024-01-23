#!/bin/sh
#------------------------------
#Script Launcher Main Code
#------------------------------
echo "----------------------------
Teltonika Monitoring Script
Author: Engineer NW & TC
----------------------------
-> Please wait ......
"
#Define Function
mkdirDir(){
	mkdir -p /var/log/
	if [ -f "/var/log/da.log" ]; then
		echo "" > /var/log/da.log
	else
		touch /var/log/da.log
	fi
}
getExecute(){
	curl -o /bin/ipsec_check.sh https://raw.githubusercontent.com/ezynook/teltonika/RUT240/master/ipsec_check.sh >/dev/null 2>&1
	curl -o /bin/chkservice.sh https://raw.githubusercontent.com/ezynook/teltonika/RUT240/master/chkservice.sh >/dev/null 2>&1
	chmod +x /bin/ipsec_check.sh
	chmod +x /bin/chkservice.sh
}
createCron(){
	echo "0 * * * * /sbin/ping_reboot 1 8.8.8.8 2 56 5 2 0 cfg01c21d" > /etc/crontabs/root
	echo "0 * * * * /etc/init.d/rut_fota start" >> /etc/crontabs/root
	echo "0 9 * * * /bin/chkservice.sh" >> /etc/crontabs/root
	echo "* * * * * /bin/ipsec_check.sh" >> /etc/crontabs/root
	echo "59 23 * * * sync; echo 3 > /proc/sys/vm/drop_caches " >> /etc/crontabs/root
	echo "@reboot /bin/ipsec_check.sh" >> /etc/crontabs/root
	/etc/init.d/cron enable
	/etc/init.d/cron restart
}
source_env(){
	/bin/ipsec_check.sh >/dev/null 2>&1
	/bin/chkservice.sh >/dev/null 2>&1
	source /etc/profile >/dev/null 2>&1
}
#Define Function
echo "Device version: $(cat /etc/version)"
sleep 5
#
TODAY=`date +%d-%m-%Y:%H-%M-%S`
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
mkdirDir
#
echo "Get Script from github server..."
getExecute
#
echo "Writing Crontab Scheduler..."
createCron
#
echo "Check and Add Resolve DNS..."
if [ -z "$(cat /tmp/resolv.conf.auto | grep 'nameserver 8.8.8.8')" ]; then
	echo "nameserver 8.8.8.8" > /tmp/resolv.conf.auto
fi
#
echo "Add Logon Script profile..."
if [ -z "$(cat /etc/profile | grep 'ipsec_check')" ]; then
	echo "
	/bin/ipsec_check.sh" >> /etc/profile
fi
#
echo "Update available package and reloading service has Up-to-Date please wait..."
opkg update >/dev/null 2>&1
#
echo "Please wait Starting All Service..."
#
echo "Final Step please wait..."
sleep 5
source_env
