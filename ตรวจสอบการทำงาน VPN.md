### ตรวจสอบการทำงานของ VPN และ Network พร้อมส่ง Line Notify Teltonika
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
