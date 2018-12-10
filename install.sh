#!/bin/bash
#                         __
#                      _,'  `:--.__
#                    ,'    .       `'--._
#                  ,'    .               `-._
#          ,-'''--/    .                     `.
#        ,'      /   .    ,,-''`-._            `.
#       ; .     /   .   ,'         `,            |____
#       |      /   .   ;             :           |--._\
#       '     /   :    |      .      |           |
#        `.  ;   _     :             ;           |
#          `-:   `"     \           ,           _|==:--.__
#             \.-------._`.       ,`        _.-'     `-._ `'-._
#              \  :        `-...,-``-.    .'             `-.   | 
#               `.._         / | \     _.'                  `. | 
#                   `.._    '--'```  .'                       `|
#                       `.          /
#                .        `-.       \
#         ___   / \  __.--`/ , _,    \
#       ,',  `./,--`'---._/ = / \,    \  __
#      /    .-`           `"-/   \)_    "`
#    _.--`-<_         ,..._ /,-'` /    /
#  ,'.-.     `.    ,-'     `.    /`'.+(
# / /  /  __   . ,'    ,   `.  '    \ \ 
# |(_.'  /  \   ; |          |        ""_
# |     (   ;   `  \        /           `.
# '.     `-`   `    `.___,-`             `.
#   `.        `                           |
#    ; `-.__`                             |
#    \    -._                             |
#     `.                                  /
#      /`._                              /
#      \   `,                           /
#       `---'.     /                  ,'
#             '._,'-.              _,(_,_
#                    |`--.    ,,.-' `-.__)
#                     `--`._.'         `._)
#                                         `=-
# ____  ___ ____  _____   _____ _   _ _____   ____ ___ ____ _ 
#|  _ \|_ _|  _ \| ____| |_   _| | | | ____| |  _ \_ _/ ___| |
#| |_) || || | | |  _|     | | | |_| |  _|   | |_) | | |  _| |
#|  _ < | || |_| | |___    | | |  _  | |___  |  __/| | |_| |_|
#|_| \_\___|____/|_____|   |_| |_| |_|_____| |_|  |___\____(_)
#
# A script by Patrick Veronneau
#
# Version 1.0
#
#
# Side note: Nicole Matsui is a jerk for making me comment.
#
#### Install tang server on raspberry pi zero and add Adafruit SSD1306 OLED support
# Verify this is run by root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo '>>> Install tang and start the service'
apt-get update -y
apt-get install -y tang
systemctl enable tangd.socket
systemctl start tangd.socket
# ssh 127.0.0.1 tang-show-keys 
echo "Server Thumbprint Key"
jose jwk thp -i /var/db/tang/*.jwk
# enable I2C on Raspberry Pi totally jacked from (http://www.uugear.com/portfolio/a-single-script-to-setup-i2c-on-your-raspberry-pi/)
echo '>>> Enable I2C'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q 'i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q 'enable_uart=1' /boot/config.txt; then
  echo 'Seems uart parameter already set, skip this step.'
else
  echo 'enable_uart=1' >> /boot/config.txt
fi
if grep -q 'dtparam=i2c1=on' /boot/config.txt; then
  echo 'Seems i2c1 parameter already set, skip this step.'
else
  echo 'dtparam=i2c1=on' >> /boot/config.txt
fi
if grep -q 'dtparam=i2c_arm=on' /boot/config.txt; then
  echo 'Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi
if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then
  sed -i 's/^blacklist spi-bcm2708/#blacklist spi-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
  sed -i 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
else
  echo 'File raspi-blacklist.conf does not exist, skip this step.'
fi
# install i2c-tools
echo '>>> Install i2c-tools'
if hash i2cget 2>/dev/null; then
  echo 'Seems i2c-tools is installed already, skip this step.'
else
  apt-get install -y i2c-tools
fi
echo 'Installing additional packages'
apt-get install -y build-essential python-dev python-pip python-pil python-smbus git python-smbus
pip install RPi.GPIO
git clone https://github.com/adafruit/Adafruit_Python_SSD1306.git && python Adafruit_Python_SSD1306/setup.py install
# Setup script directory
mkdir -p /opt/tang-oled
cp tang-oled.py /opt/tang-oled/tang-oled.py
cp font/pixelmix.ttf /opt/tang-oled/pixelmix.ttf
# setup systemd service
cat > /lib/systemd/system/tang-oled.service << EOF
[Unit]
Description=Script to run the OLED screen to show tangd monitoring

[Service]
Type=simple
ExecStart=/opt/tang-oled/tang-oled.py
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start tang-oled.service
systemctl enable tang-oled.service
