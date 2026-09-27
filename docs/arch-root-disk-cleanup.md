# Cleaning a Full Root Partition on Arch Linux

This guide collects useful commands for diagnosing and cleaning a full root
partition on Arch Linux.

It is intended for the situation where `/` is full, but `/home` still has
space.

## 1. Check disk usage

Start with:

```bash
df -h
df -h /
```

Example problem:

```text
/dev/mapper/ArchinstallVg-root   20G   19G     0 100% /
/dev/mapper/ArchinstallVg-home  895G  498G  353G  59% /home
```

This means the root filesystem is full, while the home partition still has
space.

## 2. Find large directories on `/`

Use `-x` to stay on the root filesystem and avoid crossing into `/home`,
`/boot`, or other mounted filesystems.

```bash
sudo du -xhd1 / | sort -h
```

Inspect large subdirectories:

```bash
sudo du -xhd1 /var | sort -h
sudo du -xhd1 /usr | sort -h
sudo du -xhd1 /root | sort -h
sudo du -xhd1 /opt | sort -h
```

For more detail:

```bash
sudo du -xhd2 /var /usr /root /opt 2>/dev/null | sort -h | tail -80
```

## 3. Find large individual files

This is often the most useful command:

```bash
sudo find / -xdev -type f -size +100M -printf '%s\t%p\n' \
  | sort -nr \
  | numfmt --field=1 --to=iec \
  | head -50
```

It lists large files on the root filesystem only.

Examples of suspicious files:

```text
/var/lib/ollama/blobs/*-partial
/var/log/*.log
/root/.cache/*
/root/.npm/*
/mnt/pi_boot/*
```

Do not manually delete random files in `/usr`. Files in `/usr` usually belong
to packages and should be removed with `pacman`.

## 4. Check for deleted files still using space

Sometimes a file has been deleted but is still held open by a running process.
The space is not freed until the process exits.

```bash
sudo lsof +L1
```

If this shows large deleted files, restart the relevant service or reboot:

```bash
sudo reboot
```

## 5. Clean pacman cache

First try the safer cache cleanup:

```bash
sudo paccache -rk1
```

If `paccache` is not available:

```bash
sudo pacman -Sc
```

Emergency cleanup:

```bash
sudo rm -f /var/cache/pacman/pkg/download-*
sudo rm -f /var/cache/pacman/pkg/*.pkg.tar.*
```

Check the result:

```bash
df -h /
```

## 6. Clean system logs

Check journal size:

```bash
journalctl --disk-usage
```

Reduce journal size:

```bash
sudo journalctl --vacuum-size=500M
```

More aggressive:

```bash
sudo journalctl --vacuum-size=100M
```

Old rotated logs can also be removed:

```bash
sudo rm -f /var/log/*.old /var/log/*.log.* /var/log/*.[0-9]
```

## 7. Clean root-owned caches

Check root's cache directories:

```bash
sudo du -xhd1 /root | sort -h
```

Common cleanup targets:

```bash
sudo rm -rf /root/.cache
sudo rm -rf /root/.npm
```

These often appear after using tools with `sudo`.

## 8. Clean failed Ollama downloads

Failed Ollama model downloads can be very large.

Check:

```bash
sudo du -sh /var/lib/ollama 2>/dev/null
sudo find /var/lib/ollama -type f -size +100M 2>/dev/null
```

Stop Ollama:

```bash
sudo systemctl stop ollama 2>/dev/null
```

Remove partial downloads:

```bash
sudo rm -f /var/lib/ollama/blobs/*-partial
```

If Ollama is not needed, remove it completely:

```bash
sudo pacman -Rns ollama ollama-vulkan
sudo rm -rf /var/lib/ollama
```

## 9. Check accidental files in `/mnt`

Files in `/mnt` can accidentally be stored on `/` if the target filesystem was
not mounted.

Check:

```bash
sudo du -sh /mnt
findmnt /mnt/pi_boot
```

If `findmnt` prints nothing, the directory is not a mounted filesystem.

Move old files to `/home` instead of keeping them on `/`:

```bash
mkdir -p ~/old-root-files
sudo mv /mnt/pi_boot ~/old-root-files/pi_boot
```

Or delete them if they are no longer needed:

```bash
sudo rm -rf /mnt/pi_boot
```

## 10. Clean Docker and container data

Check sizes:

```bash
sudo du -sh /var/lib/docker 2>/dev/null
sudo du -sh /var/lib/containerd 2>/dev/null
```

If Docker is used, prefer Docker's own cleanup commands:

```bash
docker system df
docker system prune
```

More aggressive:

```bash
docker system prune -a
```

Only remove containerd data manually if you know you do not need local
containers or Kubernetes workloads:

```bash
sudo systemctl stop docker 2>/dev/null
sudo systemctl stop containerd 2>/dev/null
sudo rm -rf /var/lib/containerd
```

## 11. Remove unused packages

List explicitly installed packages:

```bash
pacman -Qe
```

Show explicitly installed packages sorted by size:

```bash
pacman -Qi $(pacman -Qqe) | awk '
  /^Name/ {name=$3}
  /^Installed Size/ {
    size=$4
    unit=$5
    if (unit == "KiB") size=size/1024
    if (unit == "GiB") size=size*1024
    printf "%8.1f MiB  %s\n", size, name
  }
' | sort -h | tail -40
```

Remove unused packages with dependencies:

```bash
sudo pacman -Rns package-name
```

Examples:

```bash
sudo pacman -Rns sagemath sagemath-doc
sudo pacman -Rns libreoffice-still
sudo pacman -Rns quarto-cli
sudo pacman -Rns tor-browser-alpha-bin
```

Do not remove essential packages such as:

```text
base
grub
linux
linux-hardened
amd-ucode
git
```

Do not remove all installed kernels.

## 12. Remove orphan packages

List orphaned packages:

```bash
pacman -Qtdq
```

If the command prints package names, remove them:

```bash
orphans=$(pacman -Qtdq)
[ -n "$orphans" ] && sudo pacman -Rns $orphans
```

## 13. Update after cleanup

After freeing at least a few GB:

```bash
df -h /
sudo pacman -Syu
```

Aim to keep several GB free on `/`.

For a development machine, a 20G root partition is tight. If the system uses
LVM, consider increasing `/` to at least 40G or 50G.

Check LVM layout:

```bash
sudo vgs
sudo lvs
```

## 14. Quick emergency checklist

Run these first:

```bash
df -h /

sudo find / -xdev -type f -size +100M -printf '%s\t%p\n' \
  | sort -nr \
  | numfmt --field=1 --to=iec \
  | head -50

sudo du -xhd1 / | sort -h
sudo lsof +L1
```

Then clean obvious safe targets:

```bash
sudo rm -f /var/cache/pacman/pkg/download-*
sudo journalctl --vacuum-size=100M
sudo rm -rf /root/.cache
sudo rm -rf /root/.npm
```

Check again:

```bash
df -h /
```
