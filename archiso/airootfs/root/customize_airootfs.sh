#!/usr/bin/env bash

set -e



rebuild_suckless()
{
    local dir="$1"
    cd "$dir" || return 1
    make clean install
}

rebuild_suckless /opt/devel-os/dwm
rebuild_suckless /opt/devel-os/dmenu
rebuild_suckless /opt/devel-os/dwmblocks-async

cd ~

chmod +x /usr/local/bin/start-dwm
chmod +x /usr/local/bin/dwmblocks-memory.sh
chmod +x /usr/local/bin/dwmblocks-cpu.sh
chmod +x /usr/local/bin/dwmblocks-datetime.sh

if id -u devel >/dev/null 2>&1 && [ -d /home/devel ]; then
    chown -R devel:devel /home/devel
fi

systemctl enable ly@tty1.service
