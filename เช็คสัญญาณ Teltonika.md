## **เช็คสัญญาณเราเตอร์แล้ว Restart**
##### วิธีการอ่านค่าสัญญาณ
```bash
#   >= -70 dBm	= ดีมาก
#   -70 dBm to -85 dBm = ดี
#   -86 dBm to -100 dBm = พอใช้
#   < -100 dBm	= แย่
#   -110 dBm = สัญญาณหาย
```
##### วิธีการติดตั้ง
1. Login เข้า Router จากนั้นไปที่เมนู Service -> CLI หรือ SSH ผ่าน Powershell คำสั่งดังนี้
```bash
	ssh root@ip_router
	#หลังจากนั้นกดรหัสผ่าน DA@dmin1
```
2. Copy คำสั่งนี้ไปวางตามลำดับ
```bash
cd /root/
wget http://engineer:engineer@58.137.140.160/check_signal.sh
chmod +x /root/check_signal.sh
./check_signal.sh
```
3. สุดท้ายเราจะต้องเอาไฟล์นี้ไปให้ Router ทำการรันทุกๆกี่นาทีที่เราต้องการ วิธีทำดังนี้
```bash
echo "*/10 * * * * /root/check_signal.sh" >> /etc/crontabs/root
```
*เสร็จเรียบร้อย*
<hr>
<b>พัฒนาโดย:</b> *Pasit Y.*
