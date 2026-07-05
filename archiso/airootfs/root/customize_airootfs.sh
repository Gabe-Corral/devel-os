#!/usr/bin/env bash

set -e

cd ~

if id -u devel >/dev/null 2>&1 && [ -d /home/devel ]; then
    chown -R devel:devel /home/devel
fi

if [ -x /usr/lib/develos/sync-os-release ]; then
    /usr/lib/develos/sync-os-release
fi

/usr/lib/develos/sync-calamares-config

if [ -x /usr/lib/develos/sync-ly-config ]; then
    /usr/lib/develos/sync-ly-config
fi

systemctl enable NetworkManager.service
systemctl enable systemd-resolved.service
systemctl enable ly@tty1.service
