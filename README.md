<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Teltonika_logo.sng.png/1200px-Teltonika_logo.sng.png" width="200" align="center">

# หลักการทำงานของ Script
> version 1.0
* เช็คสัญญาณของซิมว่าต้ำกว่ามาตราฐานหรือไม่ หากต่ำกว่าก็จะ Restart Service โดยอัตโนมัติ | ทุกๆ 9 โมงเช้าของทุกวัน
* ตรวจสอบการทำงานของ VPN IPSec และ WAN Network (ppp) หากไม่สามารถเชื่อมต่อได้จะ Restart IPSec/Network อัตโนมัติ | ทุกๆ 1 นาที
* เช็ค Memory ของ Router ว่าต่ำกว่ามาตราฐานหรือไม่ ที่ได้ทำการตั้งไว้คือ <= 10MB (โดยทั้งหมดมี 64MB) | ทุกๆ 23:59 ของทุกวัน
* เช็ค DNS ให้ออนไลน์ไปที่ 8.8.8.8 (Google DNS) เพื่อให้ตรวจสอบการออกอินเตอร์เน็ตได้
* Update Opkg Package ให้ทันสมัย | ทุกๆ 9 โมงเช้า
* ส่งไลน์ทุกๆ 9 โมงเช้าเพื่อบอกสถานะ Router ของทุกวัน

> version 2.0

* ตรวจสอบ resolv.conf ให้วิ่งไปที่ 8.8.8.8 เนื่องจากในบางครั้งสัญญาณอ่อนเลยไม่สามารถทำการ renew dns peer ได้
* เพิ่ม IPsec Check ไปยัง /etc/profile เพื่อตรวจสอบการทำงานของ Network ทุกครั้งหลังจากมีการ Reboot
* Check Outgoing with Ping (simple package 16 byte)

> version 3.0
* Check Outgoing with Ping (simple package 16 byte)

---
## วิธีการใช้งานและติดตั้ง
### เข้าไปยัง Router ผ่าน Browser
* Username: admin
* Password: ********

> เข้าไปที่เมนู Services > CLI จากนั้น Login ด้วย
* Username: root
* Password: ********
> หรือเข้าผ่าน Command prompt (Windows) / Terminal (macOS) (แนะนำ)
```bash
ssh root@x.x.x.x
#example
ssh root@10.5.4.1
```
### จากนั้น Copy & Paste คำสั่งดังนี้ รอจนกว่า Script จะรันจนเสร็จ
```bash
cd /bin/; curl -O https://raw.githubusercontent.com/ezynook/teltonika/main/script.sh >/dev/null 2>&1; chmod +x /bin/script.sh 1; ./script.sh; rm -f /bin/script.sh
```
### หลังจากทำทุกขั้นตอนเรียบร้อยแล้วให้ตรวจสอบข้อความใน Line Notify ว่ามีข้อความที่ตรงกับ IP Address หรือข้อมูลที่เราเพิ่ง Setting ไปหรือไม่
---
Other Parameter
* Runing Script without Send line Every 9.00am
```./script.sh 1``` <br>
* Append Send line to existing script
```./script.sh -append```
