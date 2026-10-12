# SECURITY

A security review of this `dotfiles-local` repository and the files it
checks in, plus the state of the on-disk `private/` package it is meant
to pair with (which is not tracked in git).

See `docs/SECURITY.md` for the short public-facing policy note. This
file is the detailed review. Findings are grouped by severity; each one
names the file / path, says what the risk is, and gives a concrete fix.

Threat model (same as the base repo):

- An attacker who can read `$HOME` as another local UID (daemons running
  as `nobody`/`systemd-timesync`/`pipewire` etc.; shared accounts;
  recovery boots).
- Accidental publishing of secrets through commits/pushes.
- A hostile file placed under `$HOME` by a careless script or a tool
  running as you.
- Reconnaissance from the public mirror of this repo.

---

## Resolution status

Each row below has a type:

- **FIX** — a code / config change landed in a commit. Verified.
- **AUDIT** — an audit was performed to decide whether a change was
  needed. The outcome (and the evidence used to reach it) is recorded.
- **DECISION** — the user explicitly chose how to resolve a judgment-
  call item. The decision is recorded with its date.
- **NON-ISSUE** — the original finding did not reflect reality.

Not every security finding is a bug to patch — some are policy choices
or draft overstatements. The language below says which, with evidence,
so future-you can tell the difference without re-reading the transcript.

| ID  | Type / Status        | Commit        | Evidence / Notes |
|-----|----------------------|---------------|------------------|
| H1  | FIX + verified live  | `386eacd`     | `chmod 0700` applied to every directory under `~/.dotfiles-local/private/` and the live `~/.config/{sops,gh,rclone,immich,borg,age,helm,Nextcloud,cat_installer,nvim-legacy}` targets. Files remain 0600. Re-verified 2026-10-13 with `find ... ! -perm 700` returning empty. |
| H2  | FIX                  | `386eacd`     | `.bashrc.local` wraps `~/.bashrc.private` sourcing in a `source_private`-equivalent check (ownership, mode, parent-dir perms); uses the base helper when defined. |
| M1  | FIX (README scrub) + DECISION (repo stays public) | `386eacd`, `73c0c1c` | **Fix:** README's enumeration of secret stores dropped on 2026-10-13 (`386eacd`); gitleaks pre-commit hook refuses future `private/` paths. **Audit evidence for keeping public:** (1) `gh repo view hschoss/dotfiles-local` confirms public; (2) `git grep` across tracked content → only `hschoss` (GitHub handle, unavoidable) and `arch-schlaeptop` as a dir name remain; (3) `gitleaks git` full history → `no leaks found`. **Decision:** User chose "No — keep it public" via `AskUserQuestion` on 2026-10-13. |
| M2  | AUDIT → no change needed | n/a       | `~/.local/share/applications/claude-code-url-handler.desktop` has `Exec="/home/hannes/.local/bin/claude" --handle-uri %u`. `%u` is passed as a single argv entry (not via `sh -c`); trust delegates to Claude's own URL parser. Not a shell-injection path. No code change applies. |
| M3  | FIX                  | `386eacd`     | GTK bookmarks moved to `private/.config/gtk-3.0/bookmarks` (not tracked); public tree no longer carries the username in `file://` URLs. Tracked file removed via `git rm`. |
| M4  | FIX                  | `386eacd`     | `scripts/hooks/pre-commit` refuses any staged path under `private/`. Relocating `private/` entirely outside the repo is listed as a "longer-term" consideration below; not actioned by this review. |
| M5  | FIX                  | `386eacd`     | `.gitignore` is allowlist-first with denylist retained as defense-in-depth. |
| M6  | FIX                  | `386eacd`     | `[Panels] CookieId` stripped from `media/.config/obs-studio/basic/profiles/Untitled/basic.ini`. |
| M7  | FIX                  | `73c0c1c`     | Sway autostart of `vim ~/tracker.csv` now guards on file existing + `-O` (owned by me) + no group/other-write via `find`. |
| L1  | FIX + ONGOING helper | `73c0c1c`     | Stale OBS `logs/`, `profiler_data/`, `crashes/` directories removed from the working tree; `scripts/check.sh` now reports stale app-generated junk on every run so cleanup is routine. |
| L2  | FIX                  | `386eacd`     | `scripts/check.sh` fails if `git ls-files -i --exclude-standard --cached` returns anything. |
| L3  | FIX                  | `386eacd`     | Stray `arch-schlaeptop/.config/alacritty/alacritty → /usr/bin/alacritty` symlink `git rm`'d. |
| L4  | FIX                  | `73c0c1c`     | gem bin uses `path_append`, not `path_prepend`. |
| L5  | FIX (gitconfig.local) + policy on empty files | `73c0c1c` | SSH signing config now lives in `local-git/.gitconfig.local`. The remaining empty override files (`.tmux.conf.local`, `.vimrc.local`) are intentionally empty placeholders; adding content is a user action, not a security item. |
| L6  | FIX                  | `386eacd`     | `scripts/hooks/pre-commit` + `pre-push` committed; `core.hooksPath = scripts/hooks` set via `git config --local`. |
| L7  | NON-ISSUE (clarified) | n/a           | `.bak` files were **never tracked**: `git ls-files '*.bak'` returned empty. The original `.gitignore` already matched `**/*.bak`. The earlier SECURITY.md draft overstated the finding; the stray working-tree copies have been deleted. |
| L8  | ADDRESSED by M3 + the M1 README scrub | n/a    | Covered by the public-mirror hygiene work above. Audit outcome identical to M1's. |

### On-disk hardening (not git-tracked, verified live)

| Thing | Status |
|-------|--------|
| `~/.dotfiles-local/private/` tree | all directories 0700, all files 0600 (verified 2026-10-13) |
| `~/.config/{sops,gh,rclone,immich,borg,age,...}` live targets | 0700 (verified 2026-10-13) |
| `~/.ssh/id_ed25519_hschoss.pub` referenced as `user.signingkey` | configured |
| `~/.config/git/allowed_signers` | populated with user's email + pubkey |
| Full-history `gitleaks` scan (both repos) | `no leaks found` |

### KERNEL-LIMIT: `~/.local/bin` symlink mode (surfaced during audit, not a repo item)

**Finding** `find ~/.local/bin -perm /o+w` reports 80 symlinks with
mode `0777` (TeX Live, `claude`, `codex`).

**Why it cannot be "fixed"**

> **man 7 symlink** (POSIX / Linux): *On Linux, the permissions of a
> symbolic link are not used in any operation; the permissions are
> always 0777 (read, write, and execute for all user categories), and
> can't be changed.*

Verified in-session: `chmod -h 0755 <symlink>` on ext4 is a silent
no-op; `stat` continues to report `0777`. There is no kernel API to
change this.

**Why it does not create an exposure**

Access to a symlink entry is governed by the containing directory, not
by the symlink's own stored mode. `~/.local/bin` is
`0755 hannes:hannes` (verified 2026-10-13 with `stat`). No other
local UID has write access to that directory, so no other UID can
create, delete, rename, or replace any entry in it, regardless of
`ls -l` output.

**Verified security property:**

- `stat -c '%a %U:%G' ~/.local/bin` → `755 hannes:hannes`
- Resolved targets (`claude`, `codex`, `latexmk`, `pdflatex`) are
  `0755 hannes:hannes`.

This is the correct resolution for a kernel-constrained finding:
document the constraint, verify the actual access property, record
the evidence.


---

## Preamble — what's already fine

Before the findings, so you don't rotate anything you don't have to:

- `private/` is correctly ignored by `.gitignore` and NOT tracked.
  `git check-ignore -v private/.config/sops/age/keys.txt` confirms it is
  excluded via `.gitignore:61`.
- A fast grep over the full git history did not find PEM headers, AWS
  AKIA keys, `ghp_`/`github_pat_` tokens, or obvious `password=`/`token=`
  patterns in previous commits. Run `gitleaks git` yourself for the
  definitive check.
- The sensitive files themselves are mode 0600:
  `sops/age/keys.txt`, `borg/keys/*.txt`, `rclone.conf`,
  `gh/hosts.yml`, `immich/auth.yml`, `pulse/cookie`.

So nothing is on fire. The findings below are *reduce the blast radius*
items, with one real foot-gun (**H2**) that I'd fix today.

---

## High

### H1. Parent directories of secret files are world-readable (0755)

Even though the key files are 0600, several of their parents are 0755:

```
755  /home/hannes/.dotfiles-local/private
755  /home/hannes/.dotfiles-local/private/.config
755  /home/hannes/.dotfiles-local/private/.config/sops        # age/keys.txt lives here
755  /home/hannes/.dotfiles-local/private/.config/gh          # hosts.yml (gh token)
755  /home/hannes/.dotfiles-local/private/.config/rclone      # cloud creds
755  /home/hannes/.dotfiles-local/private/.config/immich      # auth.yml
755  /home/hannes/.dotfiles-local/private/.config/go/telemetry  # upload.token
```

On a strictly single-user machine this is usually "fine". It is not fine
if:

- Any system daemon runs as another UID (pipewire, cups, avahi, GOA,
  systemd-timesync) and gets compromised — they can `ls` and enumerate
  the paths, which is already recon.
- You ever recover-boot with a different user, mount the disk in a
  different system, or run containers that bind-mount `$HOME`.
- You use `firejail`/`bwrap` sandboxes with user-namespace isolation —
  "other" bits leak into the sandbox view.

`borg/`, `cat_installer/`, `htop/` are correctly 0700. Everything else
should be too.

**Fix:**

```sh
chmod 0700 ~/.dotfiles-local/private
find ~/.dotfiles-local/private -type d -exec chmod 0700 {} +
find ~/.dotfiles-local/private -type f -exec chmod 0600 {} +
# and the live stow targets:
chmod 0700 ~/.config/sops ~/.config/gh ~/.config/rclone ~/.config/immich \
           ~/.config/borg ~/.config/age 2>/dev/null || true
```

Consider adding a `permissions-check` step to `scripts/check.sh` that
walks `private/` and fails loudly if anything is group/other-readable.

---

### H2. `.bashrc.local` sources `~/.bashrc.private` with no permission check
(`local-shell/.bashrc.local:11`)

```sh
[ -f "$HOME/.bashrc.private" ] && . "$HOME/.bashrc.private"
```

The base repo defines a careful `source_private` helper that checks
ownership, readability, and group/other write bits before sourcing. This
line bypasses it entirely. The base `.bashrc` also sources
`~/.bashrc.local` a second time *after* `unset -f source_private`,
unguarded (see the base repo's L7). The net effect: any file at
`~/.bashrc.private` runs — regardless of ownership or permissions.

If an attacker-controlled process (a package install script, a hostile
tool run under your UID, a shared `$HOME`) drops a `~/.bashrc.private`,
you execute it on your next shell.

**Fix:** reuse the helper the base repo defines, or inline the same
checks here. Rough shape:

```sh
if declare -F source_private >/dev/null 2>&1; then
    source_private "$HOME/.bashrc.private"
elif [ -O "$HOME/.bashrc.private" ] && [ -r "$HOME/.bashrc.private" ]; then
    perm=$(stat -c %a "$HOME/.bashrc.private" 2>/dev/null)
    case "${perm: -2:1}${perm: -1}" in
        [!2367][!2367]) . "$HOME/.bashrc.private" ;;
    esac
fi
```

And `chmod 0600 ~/.bashrc.private` whenever you create it.

---

## Medium

### M1. The public mirror of this repo names everything that lives in `private/`
(`README.md:24-25`)

```
- `private`: untracked local-only package for rclone, borg, immich, GitHub CLI
  auth hosts, nextcloud state, SOPS state, and other private app state
```

Anyone browsing the public dotfiles-local repo on GitHub now knows:

- You have an age/SOPS keystore,
- You back up to a Borg repository,
- You have an Immich instance,
- You use rclone with cloud credentials,
- You store `gh` auth,
- You run Nextcloud.

Combined with the base repo's README (which names the host `schlaeptop`
and your homelab tooling — Talos, k8s, Helm, Flux), this is a solid
reconnaissance package for anyone targeting you specifically.

**Fix:** keep the local policy ("secrets live outside the repo") but
remove the concrete inventory of which services. Something like:

> `private/`: untracked, locally-managed package for host-private state
> (never committed, never pushed).

Also check whether this repo really needs to be public. The base
`dotfiles` repo is public *by design*. A `dotfiles-local` for a specific
host usually should not be — making it private on GitHub costs nothing
and removes the surface entirely. If you want the config visible to
future-you, scrub host-identifiers (user name, host name, `tracker.csv`,
Nextcloud paths) first.

### M2. `arch-schlaeptop/.config/mimeapps.list` registers a `claude-cli://` handler
(`arch-schlaeptop/.config/mimeapps.list:3`)

```
x-scheme-handler/claude-cli=claude-code-url-handler.desktop
```

Custom URL-scheme handlers are web-reachable: any page can trigger
`claude-cli://...` and the browser hands it to that `.desktop` file.
Whether this is dangerous depends entirely on what `claude-code-url-handler.desktop`
does with the argument. If it inlines the URL into a shell command, this
is a drive-by RCE. If it validates and only treats the URL as data,
you're fine.

**Fix:** read the `.desktop` file (`locate claude-code-url-handler.desktop`).
Confirm the `Exec=` line passes the URL as a single argument to a program
that parses it as data, not via `sh -c`. If you don't recall installing
or needing this handler, remove the mapping.

### M3. `arch-schlaeptop/.config/gtk-3.0/bookmarks` leaks a username
(`arch-schlaeptop/.config/gtk-3.0/bookmarks:1-3`)

```
file:///home/YOUR_USER/Nextcloud
file:///home/hannes/nc
file:///home/hannes/nc/
```

Line 1 is a template placeholder (good). Lines 2–3 are the real
username. If the repo is ever made public with those lines intact, it
publishes the account name. On its own that's not fatal — but combined
with the hostname `schlaeptop` in the base README it increases
targetability.

**Fix:** either `s/hannes/YOUR_USER/g` and rely on install-time rewriting,
or move this file into `private/` and keep host-specific identifiers out
of the public tree.

### M4. `install-arch-schlaeptop.sh` stows `private/` directly under `$HOME`
(`scripts/install-arch-schlaeptop.sh:19-21`)

```sh
packages="local-shell local-tmux local-vim local-git arch-schlaeptop media"
if [ -d private ]; then
    packages="$packages private"
fi
```

Stow then creates symlinks like
`~/.config/sops/age/keys.txt → ~/.dotfiles-local/private/.config/sops/age/keys.txt`.

Two consequences:

1. **Perms must be right at the source**, because stow does not fix them —
   this is **H1**'s point of entry.
2. **The symlink target lives inside a git working tree.** If the ignore
   rules ever regress (someone un-ignores `private/`, or a script does
   `git add -f private/`), you push plaintext secrets. The `.gitignore`
   is defense in depth; it is not a vault.

**Fix:** keep `private/` under a *separate* directory outside the
dotfiles tree (e.g. `~/.local/share/dotfiles-private/`) and point stow
there (`stow --dir=/path/outside/repo private`). The secrets then cannot
be committed by accident even if `.gitignore` is edited. If you keep the
current layout, add a `pre-commit` hook that aborts on any file inside
`private/` reaching the index:

```sh
# .git/hooks/pre-commit
if git diff --cached --name-only | grep -q '^private/'; then
    echo "refusing to commit paths under private/" >&2
    exit 1
fi
```

### M5. `.gitignore` is a denylist (same pattern as the base repo)

The list is good — `**/*token*`, `**/*secret*`, `**/*credential*`,
`**/keys.txt`, `**/*.pem`, `**/*.key`, `**/.netrc`, `**/.git-credentials`,
`**/pulse/cookie` — but still gets whatever you forgot. In particular,
these are not covered today:

- `**/*.jks`, `**/*.keystore`, `**/*.ovpn`, `**/wg*.conf`, `**/*.wg`
- `**/*.agekey` *is* listed; `**/age.key`, `**/*.age` are not
- `.password-store/`, `.config/pass/`, `.config/op/`, `.config/doctl/`,
  `.config/gcloud/`
- `**/*.enc`, `**/*secrets.yaml`, `**/secrets.yml`
- `.ssh/`, `authorized_keys` — not here now, but one `cp` away

**Fix:** flip to an allowlist. In this repo the tracked file set is only
~30 paths; making the tree opt-in costs you a one-time pass and removes
the whole "I forgot to ignore X" risk forever. Add `gitleaks` as a
`pre-commit`/`pre-push` hook; `scripts/check.sh` already prints an
exhortation but does not enforce.

### M6. OBS `CookieId` is a stable device identifier
(`media/.config/obs-studio/basic/profiles/Untitled/basic.ini:112`)

`CookieId=BFE50A86A87683EB` is a per-install identifier used by OBS
browser panels for cookie storage. On its own it isn't a secret; across
multiple leaks it can be used to correlate your installations.

**Fix:** `.gitignore` already excludes `**/.config/obs-studio/user.ini`
and `plugin_config/`. Add `**/.config/obs-studio/basic/profiles/**/basic.ini`
(or at least drop the `[Panels]` section before committing). The rest of
OBS basic config is fine to track.

### M7. `arch-schlaeptop/.config/sway/config` auto-opens `~/tracker.csv` on login
(`arch-schlaeptop/.config/sway/config:202`)

```
exec alacritty -e vim ~/tracker.csv
```

Not strictly a security issue — but it means `vim` runs on a file in
your home dir every time sway starts. If `~/tracker.csv` is ever
replaced with a crafted file and modelines are not disabled in your
`.vimrc`, that opens an unprompted execution path. See the base repo's
H3 on `set nomodeline`.

**Fix:** ensure `set nomodeline` / `set modelines=0` is in `.vimrc`
(carried from the base repo review), and either drop this autostart or
make it conditional on the file existing with safe permissions.

---

## Low / Hardening

### L1. OBS logs/profiler data in the working tree

```
media/.config/obs-studio/logs/2026-03-03 20-04-04.txt
media/.config/obs-studio/profiler_data/2026-03-07 12-47-12.csv.gz
```

These are gitignored (`**/.config/obs-studio/logs/` and
`**/profiler_data/` and `**/*.gz`), so they are not committed. They are
still untracked files in your working tree that may leak info in
screenshots or if you `tar` the repo. `check.sh` could prune them, or
you could set OBS's log dir outside the repo.

### L2. `scripts/check.sh` does not verify `.gitignore` is effective
(`scripts/check.sh`)

The script prints `git status --short --untracked-files=all`, which is
nice, but a `.gitignore` regression (someone edits the file, removes a
pattern) would only show up as a new untracked file — easy to miss on a
busy status.

**Fix:** add a hard check:

```sh
leaked=$(git ls-files -i --exclude-standard --cached)
if [ -n "$leaked" ]; then
    printf 'tracked-but-should-be-ignored:\n%s\n' "$leaked" >&2
    exit 1
fi
```

### L3. `arch-schlaeptop/.config/alacritty/alacritty` is a symlink to a system binary

```
alacritty -> ../../../../../../usr/bin/alacritty
```

A symlink to `/usr/bin/alacritty` committed inside the config dir does
nothing for alacritty (which reads `alacritty.toml`, not a file named
`alacritty`). After `stow`, you end up with `~/.config/alacritty/alacritty`
pointing at the system binary — harmless but surprising. If this is
leftover from an earlier experiment, drop it; otherwise document why
it's here. There is no security consequence today.

### L4. `local-shell/.bashrc.local` prepends a user-writable path
(`local-shell/.bashrc.local:9`)

```sh
path_prepend "$HOME/.local/share/gem/ruby/3.4.0/bin"
```

Same observation as the base repo's **M2**: prepending a user-writable
directory means any gem's `bin/` wrapper shadows system binaries. For a
multi-user attacker model this matters more; for your single-user laptop
it is standard practice. Prefer `path_append` unless you actively need
override behavior.

### L5. `local-git/.gitconfig.local`, `local-tmux/.tmux.conf.local`,
`local-vim/.vimrc.local` are empty

Nothing to review — just noting that `~/.gitconfig.local` is the right
place to add `commit.gpgsign = true` and SSH signing config (see the
base repo's L4). Doing it here keeps machine identity out of the public
base repo.

### L6. No `pre-commit` / `pre-push` hooks installed

`docs/SECURITY.md` already lists the right incantations:

```sh
gitleaks detect --source . --verbose --no-banner
gitleaks git --verbose
git status --ignored --short
```

Make them hooks so you cannot forget. The minimum useful set:

- `pre-commit`: run `gitleaks protect --staged --no-banner`, reject on
  any match; also reject any staged path under `private/`.
- `pre-push`: run `gitleaks git --no-banner` (full history scan). Slow,
  but every push is a publication event.

Store the hooks under `scripts/hooks/` and set `core.hooksPath` in
`local-git/.gitconfig.local` so they are versioned.

### L7. Alacritty `.bak` files tracked in the alacritty dir

`alacritty.toml.1551bab0.bak` and `alacritty.yml.bak` are committed.
`.gitignore` ignores `**/*.bak` globally — these must have been added
before the ignore rule. Not a security issue, but if those backups ever
contained a window title with sensitive text, it's now in history.

**Fix:** `git rm` the `.bak` files and let them be ignored from now on.

### L8. GTK bookmarks includes a Nextcloud path

Already noted in **M3**, but repeating here as a hygiene item: the
`file:///home/hannes/nc` entry tells anyone who sees it (teammates
pairing on your laptop, screenshots in bug reports) exactly where your
cloud sync lives. Minor privacy, no immediate exploitation.

---

## Hardening checklist

All items from this review are resolved; see the resolution-status
table at the top for commit hashes and audit evidence.

- [x] **H1** — `chmod 0700` all directories under `~/.dotfiles-local/private/` and live `~/.config/*` targets.
- [x] **H2** — gate `~/.bashrc.private` source behind `source_private`-equivalent check.
- [x] **M1** — scrub README of concrete inventory. Repo stays public per user decision 2026-10-13.
- [x] **M2** — `.desktop` handler audited: `%u` passed as single argv, not via `sh -c`.
- [x] **M3** — GTK bookmarks relocated into `private/`.
- [x] **M4** — pre-commit hook refuses any staged `private/` path.
- [x] **M5** — `.gitignore` allowlist-first, denylist retained as defense-in-depth.
- [x] **M6** — `[Panels] CookieId` stripped from OBS `basic.ini`.
- [x] **M7** — sway tracker autostart guarded on ownership + perms.
- [x] **L1** — stale OBS logs/profiler cleaned; `check.sh` reports them ongoing.
- [x] **L2** — `check.sh` fails on `git ls-files -i --exclude-standard --cached`.
- [x] **L3** — stray `/usr/bin/alacritty` symlink `git rm`'d.
- [x] **L4** — gem bin `path_append` (not prepend).
- [x] **L5** — SSH signing config in `local-git/.gitconfig.local`.
- [x] **L6** — `scripts/hooks/pre-commit` + `pre-push` committed; `core.hooksPath` wired.
- [x] **L7** — clarified NON-ISSUE: `.bak` files were never tracked.
- [x] **L8** — covered by M3 + M1.
- [x] **Rotation precheck** — `gitleaks git` on full history of both repos: `no leaks found`.

## Rotation shortlist (if anything did leak)

If a push ever included a real secret, assume compromise and rotate:

- GitHub CLI token → `gh auth logout -h github.com && gh auth login`,
  then revoke the old token in GitHub settings.
- age/SOPS key → generate new age key, `sops updatekeys` across every
  encrypted file, re-encrypt and commit.
- Borg repo passphrase → `borg key change-passphrase`.
- rclone remotes → regenerate each remote's OAuth / API key in its cloud
  console; `rclone config reconnect <remote>:`.
- Immich auth → log out all sessions, rotate the password.
- PulseAudio/pipewire cookies → delete `~/.config/pulse/cookie`; new one
  is generated on next session.
- eduroam cert / `cat_installer` → re-run the CAT installer; revoke the
  old client cert via your institution's RA if applicable.
