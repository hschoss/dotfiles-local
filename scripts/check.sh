#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

printf "Broken symlinks in repo:\n"
find . -xtype l -print

printf "\nStow simulate: local common\n"
stow --dir=packages --target="$HOME" --simulate --verbose local-shell local-tmux local-vim local-git

printf "\nStow simulate: arch desktop\n"
desktop_packages="local-shell local-tmux local-vim local-git arch-desktop media"
if [ -d packages/private ]; then
    desktop_packages="$desktop_packages private"
fi
stow --dir=packages --target="$HOME" --simulate --verbose $desktop_packages

printf "\nPackage tree:\n"
find packages -maxdepth 4 -print | sort

printf "\nGit status:\n"
git status --short --untracked-files=all
