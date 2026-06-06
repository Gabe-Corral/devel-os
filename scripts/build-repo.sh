#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

REPO_ROOT="$(repo_root)"
REPO_DIR="${REPO_ROOT}/archiso/airootfs/opt/develos/repo"
EXTERNAL_PKG_DIR="${REPO_ROOT}/packages/external"

external_packages=(
    calamares
    ckbcomp
)

build_aur_package() {
    local package="$1"
    local build_dir="${EXTERNAL_PKG_DIR}/${package}"

    mkdir -p "$EXTERNAL_PKG_DIR"
    rm -f "$EXTERNAL_PKG_DIR/$package"-*.pkg.tar.*

    log "Building AUR package ${package}"
    rm -rf "$build_dir"
    git clone --depth 1 "https://aur.archlinux.org/${package}.git" "$build_dir"
    (cd "$build_dir" && makepkg -sf --noconfirm)
    cp "$build_dir"/*.pkg.tar.* "$EXTERNAL_PKG_DIR/"
}

stage_external_packages() {
    local package

    for package in "${external_packages[@]}"; do
        build_aur_package "$package"
    done
}

create_local_repo() {
    rm -rf "$REPO_DIR"
    mkdir -p "$REPO_DIR"

    cp "$REPO_ROOT"/packages/*/*.pkg.tar.* "$REPO_DIR"
    rm -f "$REPO_DIR"/*.sig

    repo-add "$REPO_DIR/develos.db.tar.gz" "$REPO_DIR"/*.pkg.tar.*
}

main() {
    require_cmd git
    require_cmd makepkg
    require_cmd repo-add

    stage_external_packages
    log "Creating local package repo"
    create_local_repo
}

main "$@"
