#!/bin/sh

mkdirDir(){
	mkdir -p /var/log/
	if [ -f "/var/log/da.log" ]; then
		echo "" > /var/log/da.log
	else
		touch /var/log/da.log
	fi
}
getExecute(){
	curl -o /bin/iwtc.sh https://raw.githubusercontent.com/ezynook/teltonika/refs/heads/main/master/iwtc.sh >/dev/null 2>&1
	chmod +x /bin/iwtc.sh
}
createCron(){
	echo "0 * * * * /sbin/ping_reboot 1 8.8.8.8 2 56 5 2 0 cfg01c21d" > /etc/crontabs/root
	echo "0 * * * * /etc/init.d/rut_fota start" >> /etc/crontabs/root
	echo "0 9 * * * /bin/iwtc.sh" >> /etc/crontabs/root
	echo "59 23 * * * sync; echo 3 > /proc/sys/vm/drop_caches " >> /etc/crontabs/root
	echo "@reboot /bin/iwtc.sh" >> /etc/crontabs/root
	/etc/init.d/cron enable
	/etc/init.d/cron restart
}
source_env(){
	/bin/iwtc.sh >/dev/null 2>&1
	source /etc/profile >/dev/null 2>&1
}
#Define Function
echo "Device version: $(cat /etc/version)"
sleep 3
#
TODAY=$(date +'%d-%m-%Y:%H-%M-%S')
#
echo "Check file all ready Exists...!"
if [ -n "$(ls /bin/ | grep iwtc)" ]; then
	rm -f /bin/iwtc.sh
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
if [ -z "$(cat /tmp/resolv.conf.d/resolv.conf.auto | grep 'nameserver 8.8.8.8')" ]; then
	echo "nameserver 8.8.8.8" > /tmp/resolv.conf.d/resolv.conf.auto
fi
if [ -z "$(cat /tmp/resolv.conf | grep 'nameserver 8.8.8.8')" ]; then
	echo "nameserver 8.8.8.8" > /tmp/resolv.conf
fi
#
echo "Add Logon Script profile..."
if [ -z "$(cat /etc/profile | grep 'iwtc')" ]; then
	echo "
	/bin/iwtc.sh" >> /etc/profile
fi
#
echo "Update available package and reloading service has Up-to-Date please wait..."
opkg update >/dev/null 2>&1
#
echo "Please wait Starting All Service..."
#
echo "Final Step please wait..."
sleep 3
source_env
