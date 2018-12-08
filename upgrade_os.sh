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
#### Upgrade default raspbian stretch install to buster for tang support
# Verify this is run by root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
sed -i 's/stretch/buster/g' /etc/apt/sources.list
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y