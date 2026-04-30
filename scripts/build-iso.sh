#!/usr/bin/env bash
set -euo pipefail


sync_source()
{
    local name="$1"
    local base_dir="$PWD"
    local src="$base_dir/install/$name"
    local dest="$base_dir/archiso/airootfs/opt/devel-os/$name"

    if [ ! -d "$src" ]; then
        echo "Error: source directory does not exist: $src"
        return 1
    fi

    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
}

sync_source dwm
sync_source dmenu
sync_source dwmblocks-async

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
