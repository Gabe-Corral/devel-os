#!/usr/bin/env bash
set -euo pipefail

DWM_SRC="$PWD/install/dwm"
DWM_DEST="$PWD/archiso/airootfs/opt/devel-os/dwm"
DMENU_SRC="$PWD/install/dmenu"
DMENU_DEST="$PWD/archiso/airootfs/opt/devel-os/dmenu"

rm -rf "$DWM_DEST"
mkdir -p "$(dirname "$DWM_DEST")"
cp -r "$DWM_SRC" "$DWM_DEST"

rm -rf "$DMENU_DEST"
mkdir -p "$(dirname "$DMENU_DEST")"
cp -r "$DMENU_SRC" "$DMENU_DEST"

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
