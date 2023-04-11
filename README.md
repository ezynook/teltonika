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
### เข้าไปยัง Router ผ่าน Browser
* Username: admin
* Password: DA@dmin1

> เข้าไปที่เมนู Services > CLI จากนั้น Login ด้วย
* Username: root
* Password: DA@dmin1
> หรือเข้าผ่าน CMD
```ssh root@ipaddress```
### จากนั้น Copy & Paste คำสั่งดังนี้ รอจนกว่า Script จะรันจนเสร็จ
```sh
cd /bin/; curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/script.sh; chmod +x /bin/script.sh; ./script.sh; rm -f /bin/script.sh
```
---
Other Parameter
* Runing Script without Send line Every 9.00am
```./script.sh 1``` <br>
* Append Send line to existing script
```./script.sh -append```
---

### หลังจากทำทุกขั้นตอนเรียบร้อยแล้วให้ตรวจสอบข้อความใน Line Notify ว่ามีข้อความที่ตรงกับ IP Address หรือข้อมูลที่เราเพิ่ง Setting ไปหรือไม่

---
> ### Developer | Pasit Y. | Latest release 2023.04.11
