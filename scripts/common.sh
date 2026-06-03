#!/usr/bin/env bash

script_dir() {
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd
}

repo_root() {
    local root

    if root="$(git -C "$(script_dir)/.." rev-parse --show-toplevel 2>/dev/null)"; then
        printf '%s\n' "$root"
        return
    fi

    cd -- "$(script_dir)/.." && pwd
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '==> %s\n' "$*" >&2
}

require_cmd() {
    local cmd="$1"

    command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
}

latest_iso() {
    local output_dir="$1"
    local iso=""
    local candidate

    for candidate in "$output_dir"/*.iso; do
        [ -e "$candidate" ] || continue

        if [ -z "$iso" ] || [ "$candidate" -nt "$iso" ]; then
            iso="$candidate"
        fi
    done

    [ -n "$iso" ] || die "no ISO found in $output_dir"
    printf '%s\n' "$iso"
}
