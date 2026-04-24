#!/usr/bin/env bash
set -e

cd /opt/devel-os/dwm
make clean install
cd /opt/devel-os/dmenu
make clean install
cd ~

systemctl enable ly@tty1.service
chown -R devel:devel /home/devel
