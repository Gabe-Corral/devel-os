#!/usr/bin/env bash
qemu-system-x86_64 -m 4096 -smp 2 -cdrom \
    output/archlinux-2026.04.24-x86_64.iso \
    -boot d -no-reboot
