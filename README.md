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
1. Login เข้า Router จากนั้นไปที่เมนู Adminitrator -> CLI หรือ SSH ผ่าน Powershell คำสั่งดังนี้
```bash
	ssh root@ip_router
	#หลังจากนั้นกดรหัสผ่าน DA@dmin1
```
2. พิมพ์คำสั่งสร้างไฟล์ดังนี้
```bash
	vim /root/check_signal.sh
```
3. จากนั้นจะแสดงหน้าจอดำๆ ให่กดปุ่มตัว i ที่คีย์บอร์ด แล้ววาง Code นี้ลงไป
```bash
#!/bin/sh
SIGNAL=$(gsmctl -q)
VALUE="-100"
TODAY=$(date +'%d-%m-%Y %H:%M:%S')

if [ "$SIGNAL" -lt "$VALUE" ]; then
        echo "Loss Signal Restart Device at: ${TODAY}" >> /var/log/check_signal.log
        reboot #init 6
else
        echo "Signal is Normal at: ${TODAY}" >> /var/log/check_signal.log
        exit 1
fi
```

