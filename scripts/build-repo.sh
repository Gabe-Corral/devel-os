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

stage_host_package() {
    local package="$1"
    local url filename

    mkdir -p "$EXTERNAL_PKG_DIR"
    rm -f "$EXTERNAL_PKG_DIR/$package"-*.pkg.tar.*

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

    log "Staging ${package}"
    curl -L -o "$EXTERNAL_PKG_DIR/$filename" "$url"
}

stage_external_packages() {
    local package

    for package in "${external_packages[@]}"; do
        stage_host_package "$package"
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
    require_cmd curl
    require_cmd pacman
    require_cmd repo-add

    stage_external_packages
    log "Creating local package repo"
    create_local_repo
}

main "$@"
