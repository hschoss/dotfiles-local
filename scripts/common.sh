# scripts/common.sh — shared helpers for install/unstow/check scripts.
#
# Call cd_to_repo first (needs set -eu already active). Then source
# scripts/packages.sh for the package-list variables. Then parse args
# with parse_dry_run_flag. Then invoke run_stow / run_unstow.

# Set repo_root to the repository root and cd there. Must be called
# from a script inside the repo (anywhere under scripts/).
cd_to_repo() {
    repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
    cd "$repo_root"
}

# Parse argv: accepts only an optional --dry-run flag. On success sets
# DRY_RUN=true|false. Prints usage and exits 2 on anything else.
# Usage: parse_dry_run_flag "$@"
parse_dry_run_flag() {
    DRY_RUN=false
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=true ;;
            *) printf "usage: %s [--dry-run]\n" "$0" >&2; exit 2 ;;
        esac
    done
}

# stow / unstow wrappers. All invocations go through here so flags
# (--no-folding, --dir=., --target=$HOME) have one source of truth.
run_stow() {
    if [ "${DRY_RUN:-false}" = true ]; then
        stow --no-folding --dir=. --target="$HOME" --simulate --verbose "$@"
    else
        stow --no-folding --dir=. --target="$HOME" "$@"
    fi
}

run_unstow() {
    if [ "${DRY_RUN:-false}" = true ]; then
        stow --no-folding --dir=. --target="$HOME" --delete --simulate --verbose "$@"
    else
        stow --no-folding --dir=. --target="$HOME" --delete "$@"
    fi
}

simulate_stow() {
    stow --no-folding --dir=. --target="$HOME" --simulate --verbose "$@"
}
