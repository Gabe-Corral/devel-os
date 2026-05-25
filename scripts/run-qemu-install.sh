#!/usr/bin/env bash
set -euo pipefail

# Run the DevelOS ISO in QEMU, install to a virtual disk,
# then boot again directly from the installed system.

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <iso-file> [disk-image]" >&2
    echo "Example: $0 output/develos-2026.04.25-x86_64.iso vm/develos.qcow2" >&2
    exit 1
fi

ISO="$1"
DISK="${2:-vm/develos.qcow2}"

if [ ! -f "$ISO" ]; then
    echo "Error: ISO file not found: $ISO" >&2
    exit 1
fi

# Locate OVMF (UEFI firmware) so we can boot the UEFI-only install.
OVMF_CODE=""
OVMF_VARS_TEMPLATE=""

for p in \
    /usr/share/ovmf/x64/OVMF_CODE.fd \
    /usr/share/ovmf/OVMF_CODE.fd \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/OVMF/OVMF_CODE_4M.fd \
    /usr/share/qemu/OVMF_CODE.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    /usr/share/edk2/x64/OVMF_CODE.4m.fd; do
    if [ -f "$p" ]; then
        OVMF_CODE="$p"
        break
    fi
done

for p in \
    /usr/share/ovmf/x64/OVMF_VARS.fd \
    /usr/share/ovmf/OVMF_VARS.fd \
    /usr/share/OVMF/OVMF_VARS.fd \
    /usr/share/OVMF/OVMF_VARS_4M.fd \
    /usr/share/qemu/OVMF_VARS.fd \
    /usr/share/edk2-ovmf/x64/OVMF_VARS.fd \
    /usr/share/edk2/x64/OVMF_VARS.4m.fd; do
    if [ -f "$p" ]; then
        OVMF_VARS_TEMPLATE="$p"
        break
    fi
done

if [ -z "$OVMF_CODE" ] || [ -z "$OVMF_VARS_TEMPLATE" ]; then
    echo "Error: OVMF firmware not found. Install the 'ovmf' package and then set OVMF_CODE/OVMF_VARS_TEMPLATE in scripts/run-qemu-install.sh to your actual paths." >&2
    exit 1
fi

mkdir -p "$(dirname "$DISK")"

if [ ! -f "$DISK" ]; then
    echo "Creating disk image: $DISK (40G qcow2)" >&2
    qemu-img create -f qcow2 "$DISK" 40G >/dev/null
fi

OVMF_VARS_DIR="$(dirname "$DISK")"
OVMF_VARS="$OVMF_VARS_DIR/OVMF_VARS.fd"

cp "$OVMF_VARS_TEMPLATE" "$OVMF_VARS"

echo "Booting installer ISO (UEFI/OVMF)" >&2
echo "Install DevelOS inside the VM, then poweroff or reboot from the guest." >&2

qemu-system-x86_64 \
    -m 8192 -smp 6 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -cdrom "$ISO" \
    -drive file="$DISK",if=virtio,format=qcow2 \
    -boot d -no-reboot

echo
echo "Installer VM exited. Assuming installation finished." >&2
echo "Booting from installed disk (UEFI/OVMF)" >&2

qemu-system-x86_64 \
    -m 8192 -smp 6 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -drive file="$DISK",if=virtio,format=qcow2 \
    -boot c -no-reboot
