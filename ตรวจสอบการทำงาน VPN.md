## การตรวจสอบทั้งหมดมีดังนี้
* ตรวจสอบการทำงานสัญญาณของซิมว่าเชื่อมต่อกับผู้ให้บริการหรือไม่ หากไม่ Connect จะสั่ง Restart ทันที
* ตรวจสอบการทำงานของ VPN IpSec
* ตรวจสอบแรมของเราเตอร์ว่ามีขนาดเท่าไหร่หากน้อยเกินไปจะทำการ Reset (< 10MB | Total Available 64MB)
* ตรวจสอบ Uptime ของเราเตอร์ว่าออกเน็ตได้หรือไม่โดยการอัพเดตต้องวันต่อวัน หากไม่มีการอัพเดตจะสั่ง Restart Signal
---
* Check All Service Everyday at: 09:00 AM
* Check VPN IPSec Every minute at: 1:00 Minutes
* Check Signal dB Every 15 minutes at: 15 Minutes/Hours
* Check And Clear Ram Every 23:59PM Everyday
* Check VPN IPSec Every at Logon (If failure)
* Check DNS resolve all dns nameserver to 8.8.8.8
---

## ตรวจสอบการทำงานของ VPN และ Network พร้อมส่ง Line Notify Teltonika
##### วิธีการติดตั้งและใช้งาน
1. Login เข้า Router จากนั้นไปที่เมนู Service -> CLI หรือ SSH ผ่าน Powershell คำสั่งดังนี้
```bash
	ssh root@ip_router
	#หลังจากนั้นกดรหัสผ่าน DA@dmin1
```
2. Copy คำสั่งที่ไปวางตามลำดับดังนี้
```bash
cd /bin/
wget http://engineer:engineer@58.137.140.160/script.sh
chmod +x /bin/script.sh
./script.sh
rm -f /bin/script.sh
```
