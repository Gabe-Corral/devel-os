#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

packages=(
    "develos-dwm:6.8:install/dwm"
    "develos-dmenu:5.4:install/dmenu"
    "develos-dwmblocks-async:0.1.0:install/dwmblocks-async"
)

build_package() {
    local pkgname="$1"
    local pkgver="$2"
    local src_path="$3"
    shift 3

    local pkg_dir="${repo_root}/packages/${pkgname}"
    local tarball="${pkg_dir}/${pkgname}-${pkgver}.tar.gz"

    if [ ! -d "${repo_root}/${src_path}" ]; then
        printf 'Error: source directory not found: %s\n' "${repo_root}/${src_path}" >&2
        return 1
    fi

    mkdir -p "${pkg_dir}"
    rm -f "${tarball}"

    tar \
        --exclude='*.o' \
        --exclude='build' \
        --exclude='pkg' \
        --transform "s|^${src_path}|${pkgname}-${pkgver}|" \
        -czf "${tarball}" \
        -C "${repo_root}" \
        "${src_path}"

    (cd "${pkg_dir}" && makepkg -f "$@")
}

for entry in "${packages[@]}"; do
    IFS=: read -r pkgname pkgver src_path <<< "${entry}"
    build_package "${pkgname}" "${pkgver}" "${src_path}" "$@"
done
