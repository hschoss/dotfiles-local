#!/usr/bin/env sh
set -eu
. "$(dirname -- "$0")/common.sh"
cd_to_repo
. "$repo_root/scripts/packages.sh"
parse_dry_run_flag "$@"

packages="$LOCAL_COMMON"
printf "Stowing local common packages: %s\n" "$packages"
run_stow $packages
