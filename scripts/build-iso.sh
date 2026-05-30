#!/usr/bin/env bash
set -euo pipefail

repo_dir="$PWD/archiso/airootfs/opt/develos/repo"
external_pkg_dir="$PWD/packages/external"

stage_host_package()
{
    local package="$1"
    local url filename

    mkdir -p "$external_pkg_dir"
    rm -f "$external_pkg_dir/$package"-*.pkg.tar.*

    if ! url="$(pacman -Spdd --print-format '%l' "$package")"; then
        printf 'Error: host pacman cannot resolve package: %s\n' "$package" >&2
        printf 'On Arch hosts, Calamares is not in the official repos; provide a local package or build one first.\n' >&2
        return 1
    fi

    filename="${url##*/}"

    if [ -z "$filename" ] || [ "$filename" = "$url" ]; then
        printf 'Error: could not determine package filename from URL: %s\n' "$url" >&2
        return 1
    fi

    curl -L -o "$external_pkg_dir/$filename" "$url"
}

cp archiso/packages.live.x86_64 archiso/packages.x86_64

./scripts/build-packages.sh -s --noconfirm
stage_host_package calamares
stage_host_package ckbcomp

rm -rf "$PWD/archiso/airootfs/opt/devel-os"
rm -rf "$repo_dir"
mkdir -p "$repo_dir"

cp packages/*/*.pkg.tar.* "$repo_dir"
rm -f "$repo_dir"/*.sig

repo-add "$repo_dir/develos.db.tar.gz" "$repo_dir"/*.pkg.tar.*

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
