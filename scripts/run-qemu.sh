#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

REPO_ROOT="$(repo_root)"

usage() {
    printf 'Usage: %s [iso-file]\n' "$0" >&2
    printf 'Example: %s output/develos-2026.04.25-x86_64.iso\n' "$0" >&2
}

run_qemu_live() {
    local iso="$1"

    [ -f "$iso" ] || die "ISO file not found: $iso"

    qemu-system-x86_64 -m 8192 -smp 6 -cdrom -enable-kvm \
        "$iso" \
        -device virtio-vga,xres=1920,yres=1080 \
        -display gtk,zoom-to-fit=off \
        -boot d -no-reboot
}

main() {
    if [ "$#" -gt 1 ]; then
        usage
        exit 1
    fi

    require_cmd qemu-system-x86_64

    local iso="${1:-}"

    if [ -z "$iso" ]; then
        iso="$(latest_iso "$REPO_ROOT/output")"
    fi

    run_qemu_live "$iso"
}

main "$@"
