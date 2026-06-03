#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

REPO_ROOT="$(repo_root)"

packages=(
    "develos-calamares-config:0.1.0:packages/develos-calamares-config/files"
    "develos-config:0.1.0:packages/develos-config/files"
    "develos-installer:0.1.0:packages/develos-installer/files"
    "develos-live-config:0.1.0:packages/develos-live-config/files"
    "develos-dwm:6.8:install/dwm"
    "develos-dmenu:5.4:install/dmenu"
    "develos-dwmblocks-async:0.1.0:install/dwmblocks-async"
)

build_package() {
    local pkgname="$1"
    local pkgver="$2"
    local src_path="$3"
    shift 3

    local pkg_dir="${REPO_ROOT}/packages/${pkgname}"
    local tarball="${pkg_dir}/${pkgname}-${pkgver}.tar.gz"

    if [ ! -d "${REPO_ROOT}/${src_path}" ]; then
        printf 'Error: source directory not found: %s\n' "${REPO_ROOT}/${src_path}" >&2
        return 1
    fi

    if [ "${pkgname}" = "develos-installer" ]; then
        mkdir -p "${REPO_ROOT}/${src_path}/usr/share/develos"
        cp "${REPO_ROOT}/archiso/packages.installed.x86_64" \
            "${REPO_ROOT}/${src_path}/usr/share/develos/packages.installed.x86_64"
    fi

    mkdir -p "${pkg_dir}"
    rm -f "${tarball}"
    rm -f "${pkg_dir}"/*.pkg.tar.*
    rm -rf "${pkg_dir}/pkg" "${pkg_dir}/src"

    tar \
        --exclude='*.o' \
        --exclude='build' \
        --exclude='pkg' \
        --transform "s|^${src_path}|${pkgname}-${pkgver}|" \
        -czf "${tarball}" \
        -C "${REPO_ROOT}" \
        "${src_path}"

    (cd "${pkg_dir}" && makepkg -f "$@")
}

main() {
    require_cmd makepkg
    require_cmd tar

    local entry pkgname pkgver src_path

    for entry in "${packages[@]}"; do
        IFS=: read -r pkgname pkgver src_path <<< "${entry}"
        log "Building ${pkgname}"
        build_package "${pkgname}" "${pkgver}" "${src_path}" "$@"
    done
}

main "$@"
