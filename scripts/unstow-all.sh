#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

dry_run=false
if [ "${1:-}" = "--dry-run" ]; then
    dry_run=true
    shift
fi

if [ "$#" -ne 0 ]; then
    printf "usage: %s [--dry-run]\n" "$0" >&2
    exit 2
fi

packages="local-shell local-tmux local-vim local-git arch-desktop media"
if [ -d packages/private ]; then
    packages="$packages private"
fi
printf "Unstowing local packages: %s\n" "$packages"

if [ "$dry_run" = true ]; then
    stow --dir=packages --target="$HOME" --delete --simulate --verbose $packages
else
    stow --dir=packages --target="$HOME" --delete $packages
fi
