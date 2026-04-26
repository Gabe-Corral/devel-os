#!/usr/bin/env bash
set -e

cd /opt/devel-os/dwm
make clean install
cd /opt/devel-os/dmenu
make clean install
cd /opt/devel-os/dwmblocks-async
make clean install
cd ~

chmod +x /usr/local/bin/start-dwm
chmod +x /usr/local/bin/dwmblocks-memory.sh
chmod +x /usr/local/bin/dwmblocks-cpu.sh
chmod +x /usr/local/bin/dwmblocks-datetime.sh

if id -u devel >/dev/null 2>&1 && [ -d /home/devel ]; then
    chown -R devel:devel /home/devel
fi

systemctl enable ly@tty1.service
