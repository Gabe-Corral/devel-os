#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

REPO_ROOT="$(repo_root)"
LOG_DIR="$REPO_ROOT/output/test"
LOG_FILE="$LOG_DIR/live.log"
QEMU_LOG="$LOG_DIR/live-qemu.log"
ISO_MOUNT="$LOG_DIR/iso-mount"
QEMU_PID=""

cleanup() {
    if [ -n "$QEMU_PID" ] && kill -0 "$QEMU_PID" >/dev/null 2>&1; then
        kill "$QEMU_PID" >/dev/null 2>&1 || true
        wait "$QEMU_PID" >/dev/null 2>&1 || true
    fi

    if mountpoint -q "$ISO_MOUNT"; then
        umount "$ISO_MOUNT" >/dev/null 2>&1 || umount -l "$ISO_MOUNT" >/dev/null 2>&1 || true
    fi
}

usage() {
    printf 'Usage: %s [iso-file]\n' "$0" >&2
    printf 'Example: %s output/develos-2026.07.05-x86_64.iso\n' "$0" >&2
}

wait_for_log() {
    local pattern="$1"
    local timeout_seconds="$2"
    local start now

    start="$(date +%s)"

    while true; do
        if [ -f "$LOG_FILE" ] && grep -Fq -- "$pattern" "$LOG_FILE"; then
            return 0
        fi

        now="$(date +%s)"
        if [ $((now - start)) -ge "$timeout_seconds" ]; then
            return 1
        fi

        sleep 1
    done
}

main() {
    if [ "$#" -gt 1 ]; then
        usage
        exit 1
    fi

    require_cmd qemu-system-x86_64
    require_cmd blkid
    require_cmd mount
    require_cmd umount

    local iso="${1:-}"

    if [ -z "$iso" ]; then
        iso="$(latest_iso "$REPO_ROOT/output")"
    fi

    [ -f "$iso" ] || die "ISO file not found: $iso"

    mkdir -p "$LOG_DIR"
    : >"$LOG_FILE"
    : >"$QEMU_LOG"
    mkdir -p "$ISO_MOUNT"

    if mountpoint -q "$ISO_MOUNT"; then
        umount "$ISO_MOUNT" >/dev/null 2>&1 || umount -l "$ISO_MOUNT" >/dev/null 2>&1 || true
    fi

    mount -o loop,ro "$iso" "$ISO_MOUNT"

    local kernel="$ISO_MOUNT/develos/boot/x86_64/vmlinuz-linux"
    local initrd="$ISO_MOUNT/develos/boot/x86_64/initramfs-linux.img"
    local iso_label

    iso_label="$(blkid -o value -s LABEL "$iso")"

    [ -f "$kernel" ] || die "kernel not found in ISO: $kernel"
    [ -f "$initrd" ] || die "initramfs not found in ISO: $initrd"

    log "Booting live ISO smoke test: $iso"

    qemu-system-x86_64 \
        -m 2048 \
        -smp 2 \
        -kernel "$kernel" \
        -initrd "$initrd" \
        -append "archisobasedir=develos archisolabel=$iso_label console=ttyS0,115200n8" \
        -drive file="$iso",media=cdrom,readonly=on \
        -display none \
        -serial file:"$LOG_FILE" \
        -no-reboot \
        -no-shutdown \
        -monitor none \
        -device virtio-vga \
        -device isa-debug-exit,iobase=0xf4,iosize=0x04 \
        2>"$QEMU_LOG" &

    QEMU_PID="$!"
    trap cleanup EXIT

    if ! wait_for_log 'develos login:' 180; then
        die "live ISO did not reach a login prompt; see $LOG_FILE"
    fi

    log "Live ISO smoke test passed"
}

main "$@"
