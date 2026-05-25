#!/usr/bin/env bash
set -euo pipefail

repo_dir="$PWD/archiso/airootfs/opt/develos/repo"

cp archiso/packages.live.x86_64 archiso/packages.x86_64

./scripts/build-packages.sh -s --noconfirm

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
