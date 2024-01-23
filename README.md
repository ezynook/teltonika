<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Teltonika_logo.sng.png/1200px-Teltonika_logo.sng.png" width="200" align="center">

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
curl -o /bin/script.sh https://raw.githubusercontent.com/ezynook/teltonika/RUT240/script.sh
chmod +x /bin/script.sh
./script.sh
```
### หลังจากทำทุกขั้นตอนเรียบร้อยแล้วให้ตรวจสอบข้อความใน Line Notify ว่ามีข้อความที่ตรงกับ IP Address หรือข้อมูลที่เราเพิ่ง Setting ไปหรือไม่
