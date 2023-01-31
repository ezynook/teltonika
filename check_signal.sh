#!/bin/sh

#คำสั่งไปเอาค่าสัญญาณ dBm
#-------------------------------
#   >= -70 dBm	= ดีมาก
#   -70 dBm to -85 dBm = ดี
#   -86 dBm to -100 dBm = พอใช้
#   < -100 dBm	= แย่
#   -110 dBm = สัญญาณหาย
#-------------------------------
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
