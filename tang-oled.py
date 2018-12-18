#!/usr/bin/python
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
#### Display tang server stats to the pi zero oled

import time

import Adafruit_GPIO.SPI as SPI
import Adafruit_SSD1306

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import sys
import subprocess
import commands

# Raspberry Pi pin configuration:
RST = None     # on the PiOLED this pin isnt used
# Note the following are only used with SPI:
DC = 23
SPI_PORT = 0
SPI_DEVICE = 0

# 128x32 display with hardware I2C:
disp = Adafruit_SSD1306.SSD1306_128_32(rst=RST)

# Initialize library.
disp.begin()

# Clear display.
disp.clear()
disp.display()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

# Draw some shapes.
# First define some constants to allow easy resizing of shapes.
padding = -2
top = padding
bottom = height-padding
# Move left to right keeping track of the current x position for drawing shapes.
x = 0


# Load default font.
font = ImageFont.load_default()

# Alternatively load a TTF font.  Make sure the .ttf font file is in the same directory as the python script!
# Some other nice fonts to try: http://www.dafont.com/bitmap.php
font = ImageFont.truetype('/opt/tang-oled/pixelmix.ttf', 8)

while True:

    # Draw a black filled box to clear the image.
    draw.rectangle((0,0,width,height), outline=0, fill=0)

    cmd = "hostname --fqdn"
    HOSTNAME = subprocess.check_output(cmd, shell = True )
    cmd = "hostname -I | awk \'{print \"(\" $1 \")\"}\'"
    IP = subprocess.check_output(cmd, shell = True )
    cmd = "/bin/systemctl is-active tangd.socket"
    TANG_STATUS = commands.getoutput(cmd)
    cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%sMB %.2f%%\", $3,$2,$3*100/$2 }'"
    MemUsage = subprocess.check_output(cmd, shell = True )

    # Write text.

    draw.text((x, top),       str(HOSTNAME),  font=font, fill=255)
    draw.text((x, top+8),     str(IP),  font=font, fill=255)
    draw.text((x, top+16),    "Tangd Socket: " + str(TANG_STATUS), font=font, fill=255)
    draw.text((x, top+25),    str(MemUsage),  font=font, fill=255)

    # Display image.
    disp.image(image)
    disp.display()
    time.sleep(10)