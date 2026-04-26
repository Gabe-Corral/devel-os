#!/usr/bin/env bash
set -euo pipefail

DWM_SRC="$PWD/install/dwm"
DWM_DEST="$PWD/archiso/airootfs/opt/devel-os/dwm"
DMENU_SRC="$PWD/install/dmenu"
DMENU_DEST="$PWD/archiso/airootfs/opt/devel-os/dmenu"
DWMBLOCKS_SRC="$PWD/install/dwmblocks-async"
DWMBLOCKS_DEST="$PWD/archiso/airootfs/opt/devel-os/dwmblocks-async"

rm -rf "$DWM_DEST"
mkdir -p "$(dirname "$DWM_DEST")"
cp -r "$DWM_SRC" "$DWM_DEST"

rm -rf "$DMENU_DEST"
mkdir -p "$(dirname "$DMENU_DEST")"
cp -r "$DMENU_SRC" "$DMENU_DEST"

rm -rf "$DWMBLOCKS_DEST"
mkdir -p "$(dirname "$DWMBLOCKS_DEST")"
cp -r "$DWMBLOCKS_SRC" "$DWMBLOCKS_DEST"

mkdir -p output

sudo podman build \
  --network=host \
  -t devel-os-builder .

sudo podman run --rm \
  --network=host \
  --privileged \
  --userns=host \
  --security-opt label=disable \
  -v "$PWD/archiso:/workspace/profile:ro" \
  -v "$PWD/output:/workspace/output" \
  devel-os-builder \
  bash -lc "rm -rf /tmp/archiso-work && mkarchiso -v -w /tmp/archiso-work -o /workspace/output /workspace/profile"
