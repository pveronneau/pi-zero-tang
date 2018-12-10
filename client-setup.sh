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
#### Script to setup network bound disk decryption on Redhat 8 and Fedora clients
# Verify this is run by root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "Enter the disk encrypted disk (ex. sda3):"
read DISK
if [ -z "$DISK" ]; then echo "No disk entered, abort"; exit 1; fi
echo "Enter the url of the tang server (http://tang.server.net):"
read TANGSERVER
if [ -z "$TANGSERVER" ]; then echo "No server entered, abort"; exit 1; fi
echo "### Installing packages..."
dnf install -y clevis clevis-luks clevis-dracut
echo "### Calling clevis..."
clevis luks bind -d /dev/$DISK tang '{"url":"'$TANGSERVER'"}' && dracut -f && systemctl enable clevis-luks-askpass.path && echo "Success! disk is setup to unlock after connecting to $TANGSERVER" || echo "Error, something went wrong."