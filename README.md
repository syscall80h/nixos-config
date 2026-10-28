# nixos-config

shawn's NixOS flake configuration: a forensics workstation, with one WSL
machine (no graphical interface) and one Hyprland machine (Intel).

## Architecture

```
nixos-config/
├── flake.nix                  # inputs (incl. lazyvim-nix) + mkHost: gui = (hostname != "wsl")
├── hosts/
│   ├── wsl/default.nix        # NixOS-WSL module, default user, UID 1001
│   └── laptop/
│       ├── default.nix        # boot, network, Intel GPU, bluetooth
│       └── hardware-configuration.nix   # to be generated on the machine
├── modules/                   # SYSTEM (NixOS)
│   ├── core/                  # nix, flakes, locale, nix-ld, user, updates, unfree
│   ├── dev/python.nix         # python 3.14 + uv
│   ├── virtualisation/docker.nix
│   ├── forensics/
│   │   ├── default.nix        # CLI tools (all machines)
│   │   └── gui.nix            # autopsy, ghidra, graphical wireshark (if gui)
│   └── desktop/               # Hyprland + UWSM, greetd, sound, fonts (if gui)
├── home/                      # USER (home-manager)
│   ├── theme.nix              # Catppuccin Mocha everywhere (the only place to choose the flavor)
│   ├── fish.nix               # fish, aliases, oh-my-posh, fastfetch
│   ├── lazyvim.nix            # LazyVim via lazyvim-nix → config in dotfiles/nvim
│   ├── git.nix ssh.nix tmux.nix lf.nix btop.nix claude.nix packages.nix vars.nix
│   └── gui/                   # Hyprland (Lua), hyprlock, quickshell, kitty, apps (if gui)
├── pkgs/mftecmd.nix           # MFTECmd package (Eric Zimmerman)
├── shells/                    # nix develop .#rust  /  .#go
├── wallpaper/                 # unberry_ow.jpg (to be added; without it, no hyprpaper)
└── dotfiles/
    ├── nvim/                  # LazyVim config (copied by lazyvim-nix: rebuild after editing)
    ├── oh-my-posh/            # prompt (read directly, no rebuild)
    └── eza/theme.yml          # eza theme
```

`gui` is computed in `flake.nix` from the hostname and passed to every
module. When it is `false`, `modules/desktop`, `home/gui` and
`modules/forensics/gui.nix` are simply not imported.

The repo must be in `~/nixos-config` (otherwise, change `flakeDir` in
`flake.nix`). A flake only sees files tracked by git: remember to
`git add` every new file.

## Installation on WSL (from your old configuration.nix)

```sh
git clone <your repo> ~/nixos-config      # or copy the folder, then:
cd ~/nixos-config && git init && git add -A

sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-rebuild switch --flake ~/nixos-config#wsl
```

1. The first build stops on MFTECmd with `hash mismatch … got: sha256-…`.
   Copy that value into `pkgs/mftecmd.nix` in place of `lib.fakeHash`,
   then run the command again.
2. The hostname becomes `wsl`: from PowerShell, run `wsl --shutdown`, then
   reopen the distribution.
3. After that, `rebuild` is enough (the hostname picks the right config).
4. Install the "JetBrainsMono Nerd Font" on the Windows side and select it
   in Windows Terminal: on WSL, Windows is what renders the text.

## Installation on the Hyprland machine (disko, btrfs, LUKS)

From the NixOS ISO (minimal is enough), connected to the network, **as root**:

```sh
# 0. Enable flakes for this session (nixos-install needs them)
export NIX_CONFIG="experimental-features = nix-command flakes"

# 1. Get the repo (USB key, git clone…) into /tmp/nixos-config
cd /tmp/nixos-config

# 2. Identify the disk, then set it in hosts/laptop/disko.nix (device = …)
lsblk

# 3. Partition, encrypt, format and mount on /mnt — ERASES THE DISK.
#    The LUKS password is asked here.
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount hosts/laptop/disko.nix

# 4. Generate the hardware config WITHOUT filesystems (disko describes them)
nixos-generate-config --no-filesystems --show-hardware-config --root /mnt \
  > hosts/laptop/hardware-configuration.nix

# 5. Install (git add -A first if the folder is a git repo)
nixos-install --flake .#laptop

# 6. Set shawn's password (the config defines none), then copy the repo
nixos-enter --root /mnt -c 'passwd shawn'
cp -r /tmp/nixos-config /mnt/home/shawn/nixos-config
nixos-enter --root /mnt -c 'chown -R shawn:users /home/shawn/nixos-config'
```

On reboot: LUKS password, then login in greetd.

Disk layout (`hosts/laptop/disko.nix`):

| Subvolume | Mount | Options |
|---|---|---|
| `@` | `/` | compress=zstd, noatime |
| `@home` | `/home` | compress=zstd, noatime |
| `@opt` | `/opt` | compress=zstd, noatime |
| `@nix` | `/nix` | compress=zstd, noatime |
| `@log` | `/var/log` | compress=zstd, noatime |
| `@vm` | `/var/lib/libvirt/images` | noatime + NOCOW attribute (no compression, no CoW) |

On btrfs, `compress` applies to the whole filesystem: compression on `@vm`
is turned off by the NOCOW attribute (`chattr +C`, set by a tmpfiles rule),
not by a mount option.

## Day to day

| Command | Effect |
|---|---|
| `rebuild` | applies the repo's config |
| `update` | updates `flake.lock` (security fixes) then applies; commit the lock afterwards |
| `vulnix --system` | lists the known CVEs of the installed packages |
| `nix develop ~/nixos-config#rust` | Rust shell (cargo, clippy, rust-analyzer…) |
| `nix develop ~/nixos-config#go` | Go shell (go, gopls…) |

Automatic update: every day, the system rebuilds with the latest nixpkgs
26.05, without rebooting. Reboot yourself after a kernel update.

The oh-my-posh prompt reads `dotfiles/oh-my-posh/` directly: a change
applies to the next terminal. The Neovim config (`dotfiles/nvim/`) and
Hyprland (`home/gui/hyprland/`) go through Nix: run `rebuild` after editing.

## Hyprland shortcuts (SUPER = Windows key, AZERTY keyboard)

| Key | Action |
|---|---|
| SUPER + Enter | terminal (kitty) |
| SUPER + A | launcher (quickshell) |
| SUPER + E | lf in kitty |
| SUPER + R / K | close / kill the window |
| SUPER + F | fullscreen |
| SUPER + & é " ' ( - | workspace 1 to 6 |
| SUPER + SHIFT + & é " ' ( - | move the window |
| SUPER + L | lock |
| SUPER + F1 | lock and suspend |
| SUPER + V | clipboard history (wofi) |
| SUPER + G / Z | pavucontrol / bluetooth |
| Print | screenshot of a region to the clipboard |
| SUPER + ! | quit (hyprshutdown) |
| SUPER + Space | switch keyboard layout (fr/us) |

## Choices worth knowing

- Locale `fr_FR.UTF-8`, keyboard `fr` (AZERTY), time zone `Europe/Paris`.
- No automatic mounting of disks and USB keys: evidence media must never
  be mounted without an explicit action.
- Unfree packages allowed one by one (`modules/core/default.nix`):
  volatility3, claude-code, discord.
- GTK and Qt applications in dark Adwaita (`home/gui/hyprland/env.nix`),
  Papirus Catppuccin icons.
