<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Teltonika_logo.sng.png/1200px-Teltonika_logo.sng.png" width="200" align="center">

# หลักการทำงานของ Script
* เช็คสัญญาณของซิมว่าต้ำกว่ามาตราฐานหรือไม่ หากต่ำกว่าก็จะ Restart Service โดยอัตโนมัติ | ทุกๆ 9 โมงเช้าของทุกวัน
* ตรวจสอบการทำงานของ VPN IPSec หากไม่สามารถเชื่อมต่อได้จะ Restart IPSec อัตโนมัติ | ทุกๆ 1 นาที
* เช็คการทำงานของซิม เวลาที่ Online ล่าสุดต้องไม่ต่ำกว่า 1 วัน (วันที่ Uptime ต้องตรงกับ Date Now) | ทุกๆ 15 นาที
* เช็ค Memory ของ Router ว่าต่ำกว่ามาตราฐานหรือไม่ ที่ได้ทำการตั้งไว้คือ <= 10MB (โดยทั้งหมดมี 64MB) | ทุกๆ 23:59 ของทุกวัน
* เช็ค DNS ให้ออนไลน์ไปที่ 8.8.8.8 (Google DNS) เพื่อให้ตรวจสอบการออกอินเตอร์เน็ตได้
* Update Package ให้ทันสมัย | ทุกๆ 9 โมงเช้า
* ส่งไลน์ทุกๆ 9 โมงเช้าเพื่อบอกสถานะ Router ของทุกวัน
---
## วิธีการใช้งานและติดตั้ง
### เข้าไปยัง Router
* Username: root
* Password: DA@dmin1

> เข้าไปที่ Router > Service > CLI
### จากนั้นพิมพ์คำสั่งตามลำดับดังนี้
```sh
cd /bin/
wget https://raw.githubusercontent.com/ezynook/teltonika/main/script.sh
chmod +x /bin/script.sh
./script.sh
```
### รอจนกว่าจะเสร็จและทำการลบไฟล์ออก
```sh
rm -f /bin/script.sh
```
---
> ## Developer | Pasit Y.
