#!/usr/bin/env bash

set -e

cd ~

chmod +x /usr/local/bin/develos-install

if id -u devel >/dev/null 2>&1 && [ -d /home/devel ]; then
    chown -R devel:devel /home/devel
fi

systemctl enable ly@tty1.service
