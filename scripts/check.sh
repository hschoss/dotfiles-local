#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

printf "Broken symlinks in repo:\n"
find . -xtype l -print

printf "\nStow simulate: local common\n"
stow --dir=. --target="$HOME" --simulate --verbose local-shell local-tmux local-vim local-git

printf "\nStow simulate: arch-schlaeptop\n"
desktop_packages="local-shell local-tmux local-vim local-git arch-schlaeptop media"
if [ -d private ]; then
    desktop_packages="$desktop_packages private"
fi
stow --dir=. --target="$HOME" --simulate --verbose $desktop_packages

printf "\nPackage tree:\n"
package_dirs="arch-schlaeptop local-git local-shell local-tmux local-vim media"
if [ -d private ]; then
    package_dirs="$package_dirs private"
fi
find $package_dirs -maxdepth 4 -print | sort

printf "\nGit status:\n"
git status --short --untracked-files=all
