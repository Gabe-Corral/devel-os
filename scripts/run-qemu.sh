#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <iso-file>"
    echo "Example: $0 output/archlinux-2026.04.25-x86_64.iso"
    exit 1
fi

ISO="$1"

if [ ! -f "$ISO" ]; then
    echo "Error: ISO file not found: $ISO"
    exit 1
fi

qemu-system-x86_64 -m 8192 -smp 6 -cdrom \
    "$ISO" \
    -boot d -no-reboot
