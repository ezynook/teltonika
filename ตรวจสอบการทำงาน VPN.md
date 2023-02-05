### ตรวจสอบการทำงานของ VPN และ Network พร้อมส่ง Line Notify Teltonika
<hr>
1.  Login เข้า Router จากนั้นไปที่เมนู Adminitrator -> CLI หรือ SSH ผ่าน Powershell คำสั่งดังนี้
```bash
ssh root@ip_router
	#หลังจากนั้นกดรหัสผ่าน DA@dmin1
```
2. Copy คำสั่งนี้ไปวาง
```bash
#!/bin/sh

checkipsec=`ls /bin/ | grep ipsec_check`
checkchkservice=`ls /bin/ | grep chkservice.sh`
checkcron=`ls /bin/ | grep croncheck.sh`
if [ -n "$checkipsec" ]; then
	rm -f /bin/ipsec_check.sh
fi
if [ -n "$checkchkservice" ]; then
	rm -f /bin/chkservice.sh
fi
if [ -n "$checkcron" ]; then
    rm -f /bin/croncheck.sh
fi
echo "0 * * * * /etc/init.d/rut_fota start" > /etc/crontabs/root

mkdir -p /var/log/
touch /var/log/da.log
touch /bin/chkservice.sh && chmod 775 /bin/chkservice.sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
echo '#!/bin/sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
TOKEN="JFJyi78b88GS71LEOXps5033VvAHoswaDGHlnK8jY8q" #Line Toey Tech.

if [ -z "$(gsmctl -j | grep connected)" ];
then
    echo "$TODAY -> Reboot router because GSM disconnected" >> /var/log/da.log
    reboot
else
    echo "$TODAY -> Service Sim Carrier is Normal";
    echo "Last check at: $TODAY -> Service Sim Carrier is Normal" >> /var/log/da.log
fi

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
SIGNAL=`gsmctl -q | cut -d "-" -f2`
if [ "$SIGNAL" -le "70" ]; then
    SN_STATE="ระดับสัญญาณ: -$SIGNAL dBm : สัญญาณดีมาก"
else
    SN_STATE="ระดับสัญญาณ: $SIGNAL dBm : สัญญาณแย่"
fi

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
TOTAL="$newline $title $newline $mICCID $ICCID $newline $mCarr $Carr $newline $IPm $IP $newline $IP2m $IP2 $newline $Statusm $Status $newline $SN_STATE $newline $devicem $device $newline $sitem $sitecus $newline $fwm $fw $newline $dates"
curl -X POST -H "Authorization: Bearer $TOKEN" -F "message=$TOTAL" https://notify-api.line.me/api/notify' >> /bin/chkservice.sh
echo "$TODAY -> Create ChkService Successfully"

touch /bin/ipsec_check.sh && chmod 775 /bin/ipsec_check.sh
echo '#!/bin/sh
TODAY=`date +%d-%m-%Y:%H-%M-%S`
ip="$(ifconfig | grep -A 1 "br-lan" | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1)"
ping 10.0.255.1 -I $ip -c 3 -q >/dev/null
ret=$?
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables-save
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
fi' >>  /bin/ipsec_check.sh
echo "$TODAY -> Create IPSec Successfully"

touch /bin/croncheck.sh && chmod 775 /bin/croncheck.sh
echo '#!/bin/sh
echo "" > /var/log/da.log ' >> /bin/croncheck.sh
echo "$TODAY -> Create CronCheck Successfully"


echo "0 9 * * * /bin/chkservice.sh" >> /etc/crontabs/root
echo "* * * * * /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "0 0 * * 0 /bin/croncheck.sh" >> /etc/crontabs/root
echo "@reboot /bin/ipsec_check.sh" >> /etc/crontabs/root
echo "$TODAY -> Create Cronjob Successfully"
/bin/ipsec_check.sh
/bin/chkservice.sh
```
## พัฒนาโดย: *Pasit Y.*
