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

packages="local-shell local-tmux local-vim local-git"
printf "Stowing local common packages: %s\n" "$packages"

if [ "$dry_run" = true ]; then
    stow --no-folding --dir=. --target="$HOME" --simulate --verbose $packages
else
    stow --no-folding --dir=. --target="$HOME" $packages
fi
