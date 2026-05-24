# dotfiles (local)

my local dotfiles for configuring my shell, terminal and system environment, managed with [GNU Stow](https://www.gnu.org/software/stow/)
The whole configuration is strongly inspired by [Anish
Athalye](https://github.com/anishathalye/dotfiles) and his lecture at [missing
semester](https://missing.csail.mit.edu/2026/command-line-environment/).


this repo is an extension of the my public
[dotfiles](https://github.com/hschoss/dotfiles) repo.  it installs local
overrides such as `.bashrc.local`, `.bash_profile.local`, desktop
configuration, and host-specific app settings.

## Packages

- `local-shell`: bash local overrides and local aliases
- `local-tmux`: bmux local overrides
- `local-vim`: vim local overrides
- `local-git`: git local overrides
- `arch-desktop`: sway, alacritty, gtk, dconf, wallpapers, pulseaudio, yay, and desktop session config
- `media`: mpv, obs, zathura, kiwix
- `private`: untracked local-only package for rclone, borg, immich, GitHub CLI auth hosts, nextcloud state, SOPS state, and other private app state

## Security

This repository is public. Do not commit credentials, local auth state, app
cookies, API tokens, private keys, or service-specific config files containing
secrets. Keep those files in ignored local-only packages such as
`packages/private/`.

## Dry Run

```sh
./scripts/install-local-common.sh --dry-run
./scripts/install-arch-desktop.sh --dry-run
```

## Apply

```sh
./scripts/install-local-common.sh
./scripts/install-arch-desktop.sh
```

## Check

```sh
./scripts/check.sh
```

## Packages 

those are the programs i am running on my system.

### learning about the system
* **[man-pages-de](https://wiki.archlinux.org/title/Man_page)** - German
  translations for the standard Linux manual pages in order to rtfm.
* **[tldr](https://wiki.archlinux.org/title/Man_page#tldr)** - short version of
  man pages for everyday usage

### media
* **[mpv](https://wiki.archlinux.org/title/Mpv)** - A free, lightweight,
  open-source, and cross-platform media player 
* **[yt-dlp](https://wiki.archlinux.org/title/Yt-dlp)** - cli audio and video
  downloader 
* **[wget](https://wiki.archlinux.org/title/Wget)** - cli website downloader
* **[zathura](https://wiki.archlinux.org/title/Zathura)** - vim-like pdf viewer
* **[zathura-pdf-poppler](https://wiki.archlinux.org/title/Zathura)** - zathura
  pdf support plugin 

### System
* **[networkmanager](https://wiki.archlinux.org/title/NetworkManager)** - lets
  you connect to the wifi in overly complicated ways
* **[pipewire](https://wiki.archlinux.org/title/PipeWire)** - server for
  handling audio and video streams on Linux
* **[rofi](https://wiki.archlinux.org/title/Rofi)** - window switcher,
  application launcher, and dmenu replacement
* **[rsync](https://wiki.archlinux.org/title/Rsync)** - fast and versatile file
  copying tool that synchronizes files locally or remotely.
* **[stow](https://wiki.archlinux.org/title/Stow)** - symlink manager for
  managing my dotfiles
* **[sway](https://wiki.archlinux.org/title/Sway)** - i3 window manager as a
  Wayland compositor
* **[swaybg](https://wiki.archlinux.org/title/Sway#Wallpaper)** - wallpaper
  utility for Sway (make sure to check out my wallpaper)
* **[swayidle](https://wiki.archlinux.org/title/Sway#Idle_configuration)** -
  idle management daemon for Wayland
* **[swaylock](https://wiki.archlinux.org/title/Sway#Screen_locking)** - screen
  locker for Wayland
* **[wireplumber](https://wiki.archlinux.org/title/WirePlumber)** - A modular
  session manager for PipeWire.
* **[wofi](https://wiki.archlinux.org/title/Wofi)** - A launcher/menu program
  for wlroots-based Wayland compositors (similar to Rofi).

#### Fonts
* **[noto-fonts](https://wiki.archlinux.org/title/Fonts#Noto_fonts)** - free
  font family by Google designed to cover all Unicode characters.
* **[ttf-ms-fonts](https://wiki.archlinux.org/title/Microsoft_fonts)** -
  TrueType fonts from Microsoft you kow from Word (Arial, Times New Roman,
etc.).

### Working
* **[vim](https://wiki.archlinux.org/title/Vim)** - highly configurable text
  editor for people with adhd
* **[openssh](https://wiki.archlinux.org/title/OpenSSH)** - tool for remote
  login on my home server with holy ssh
* **[pandoc-cli](https://wiki.archlinux.org/title/Pandoc)** - universal markup
  converter for switching between popular document formats
* **[tmux](https://wiki.archlinux.org/title/Tmux)** - lets you manage multiple
  terminal sessions in one window
* **[tree](https://wiki.archlinux.org/title/Core_utilities#Essentials)** -
  recursively lists directories in a tree-like format.
* **[wireguard-tools](https://wiki.archlinux.org/title/WireGuard)** - tools for
  configuring secure network tunnels.

### Languages
* **[r](https://wiki.archlinux.org/title/R)** - language and environment for
  statistical computing
* **[ruby](https://wiki.archlinux.org/title/Ruby)** - dynamic programming
  language for running my blog in jekyll
* **[python](https://wiki.archlinux.org/title/Python)** - perfect language for
  vibe coding

### Screenshot + Screenrecording
* **[scrot](https://wiki.archlinux.org/title/Scrot)** - screenshot tool
* **[slurp](https://wiki.archlinux.org/title/Screen_capture#Wayland)** - linux
  version of snipping tool
* **[obs-studio](https://archlinux.org/packages/?name=obs-studio)** - gui
  screen recorder
* **[wl-clipboard](https://wiki.archlinux.org/title/Wayland#Clipboard)** -
  Command-line copy/paste utilities 

### Package Management
* **[yay](https://wiki.archlinux.org/title/AUR_helpers#Pacman_wrappers)** - i
  rarely download stuff from the AUR
