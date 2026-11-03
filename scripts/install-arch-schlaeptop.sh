#!/usr/bin/env sh
set -eu
. "$(dirname -- "$0")/common.sh"
cd_to_repo
. "$repo_root/scripts/packages.sh"
parse_dry_run_flag "$@"

packages="$LOCAL_COMMON $LOCAL_HOST"
[ -d private ] && packages="$packages private"
printf "Stowing arch-schlaeptop packages: %s\n" "$packages"
run_stow $packages
