#!/usr/bin/env bash

set -e

cd ~

if id -u devel >/dev/null 2>&1 && [ -d /home/devel ]; then
    chown -R devel:devel /home/devel
fi

/usr/lib/develos/sync-calamares-config

if [ -f /etc/ly/lang/en.ini ]; then
    sed -i 's/^toggle_password =.*/toggle_password =/' /etc/ly/lang/en.ini
fi

systemctl enable ly@tty1.service
