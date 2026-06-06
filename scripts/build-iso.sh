#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

REPO_ROOT="$(repo_root)"

prepare_archiso_profile() {
    cp "$REPO_ROOT/archiso/packages.live.x86_64" "$REPO_ROOT/archiso/packages.x86_64"
    rm -rf "$REPO_ROOT/archiso/airootfs/opt/devel-os"
}

build_iso_container() {
    mkdir -p "$REPO_ROOT/output"

    sudo podman build \
        --network=host \
        -f "$REPO_ROOT/Containerfile" \
        -t devel-os-builder \
        "$REPO_ROOT"

    sudo podman run --rm \
        --network=host \
        --privileged \
        --userns=host \
        --security-opt label=disable \
        -v "$REPO_ROOT/archiso:/workspace/profile:ro" \
        -v "$REPO_ROOT/output:/workspace/output" \
        devel-os-builder \
        bash -lc "rm -rf /tmp/archiso-work && mkarchiso -v -w /tmp/archiso-work -o /workspace/output /workspace/profile"
}

build_packages_container() {
    sudo podman build \
        --network=host \
        -f "$REPO_ROOT/Containerfile" \
        -t devel-os-builder \
        "$REPO_ROOT"

    sudo podman run --rm \
        --network=host \
        --security-opt label=disable \
        -v "$REPO_ROOT:/workspace" \
        devel-os-builder \
        bash -lc "pacman -Syu --noconfirm && useradd -m builder && chown -R builder:builder /workspace && echo 'builder ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/builder && su builder -c 'cd /workspace && ./scripts/build-packages.sh -s --noconfirm && ./scripts/build-repo.sh'"
}

main() {
    require_cmd podman
    require_cmd sudo

    log "Preparing archiso profile"
    prepare_archiso_profile
    log "Building packages and local repo in Arch container"
    build_packages_container
    log "Building ISO"
    build_iso_container
}

main "$@"
