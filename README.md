# SilverOS

NixOS flake configuration for a forensics workstation. Two configurations:

- `wsl`: NixOS under WSL, no graphical interface;
- `silveros`: every physical machine (Hyprland), whatever its hardware.

## Architecture

```
nixos-config/
├── flake.nix                  # inputs + mkHost: gui = (host != "wsl")
├── install.sh                 # installs silveros from the NixOS ISO
├── hosts/
│   ├── wsl/default.nix        # NixOS-WSL module, default user, UID 1001
│   └── silveros/
│       ├── default.nix        # boot, network, Intel GPU, bluetooth + /etc/nixos/local.nix
│       └── disko.nix          # GPT, ESP, LUKS, btrfs subvolumes
├── modules/                   # SYSTEM (NixOS)
│   ├── core/                  # nix, locale, keyboard option, user, updates, unfree
│   ├── dev/python.nix         # python + uv
│   ├── virtualisation/        # docker.nix, libvirt.nix (KVM/QEMU + virt-manager, if gui)
│   ├── forensics/
│   │   ├── default.nix        # CLI tools (all machines)
│   │   └── gui.nix            # autopsy, ghidra, graphical wireshark (if gui)
│   └── desktop/               # Hyprland + UWSM, greetd, fonts (if gui)
├── home/                      # USER (home-manager)
│   ├── theme.nix              # Catppuccin Mocha everywhere (the only place to choose the flavor)
│   ├── fish.nix               # fish, aliases, oh-my-posh, fastfetch
│   ├── lazyvim.nix            # LazyVim via lazyvim-nix → config in dotfiles/nvim
│   ├── git.nix ssh.nix tmux.nix lf.nix yazi.nix btop.nix claude.nix packages.nix vars.nix
│   └── gui/                   # Hyprland (generated Lua), hyprlock, quickshell, kitty,
│                              # flameshot, virt-manager, apps (if gui)
├── pkgs/mftecmd.nix           # MFTECmd package (Eric Zimmerman)
├── shells/                    # nix develop .#rust  /  .#go
├── wallpaper/                 # dfir-wallpaper.png (hyprpaper)
└── dotfiles/
    ├── nvim/                  # LazyVim config (copied by lazyvim-nix: rebuild after editing)
    ├── oh-my-posh/            # prompt (read directly, no rebuild)
    └── eza/theme.yml          # eza theme
```

`gui` is computed in `flake.nix` from the configuration name and passed to
every module. When it is `false`, `modules/desktop`, `home/gui`,
`modules/forensics/gui.nix` and libvirt are simply not imported.

The repo must be in `~/nixos-config` (otherwise, change `flakeDir` in
`flake.nix`). A flake only sees files tracked by git: remember to
`git add` every new file.

### Per-machine settings: /etc/nixos/local.nix

The repo contains nothing specific to one computer, so the whole team uses
the same repo. Each silveros machine keeps its own settings in
`/etc/nixos/`, outside git, written by `install.sh`:

```nix
# /etc/nixos/local.nix
{
  imports = [ ./hardware-configuration.nix ]; # generated with --no-filesystems
  networking.hostName = "dell-shawn";
  my.keyboard = "be"; # fr, be or gb
  system.stateVersion = "26.05"; # NixOS version at install time: never change it
}
```

Reading a file outside the repo requires `--impure`: the `rebuild` and
`update` aliases and the automatic upgrade pass it.

## Installation on WSL

```sh
git clone git@github.com:syscall80h/nixos-config.git ~/nixos-config
sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-rebuild switch --flake ~/nixos-config#wsl
```

1. The hostname becomes `wsl`: from PowerShell, run `wsl --shutdown`, then
   reopen the distribution.
2. After that, `rebuild` is enough.
3. Install the "JetBrainsMono Nerd Font" on the Windows side and select it
   in Windows Terminal: on WSL, Windows is what renders the text.

## Installation on a physical machine (disko, btrfs, LUKS)

From the NixOS ISO (minimal is enough), connected to the network:

```sh
git clone https://github.com/syscall80h/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config
sudo ./install.sh          # or: sudo ./install.sh sda
```

The script asks for the machine name and the keyboard layout (loaded right
away, so the LUKS passphrase is typed with the right layout), then the disk
to **erase**, with a confirmation. It partitions with disko, writes
`/etc/nixos/local.nix` and `hardware-configuration.nix`, installs, asks for
shawn's password and copies the repo to `~/nixos-config`.

On reboot: LUKS passphrase, then login in greetd.

Disk layout (`hosts/silveros/disko.nix`):

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

### Migrating an existing machine

For a machine installed before `/etc/nixos/local.nix` existed (formerly the
`laptop` configuration). The disk layout is unchanged, nothing is erased:

```sh
sudo mkdir -p /etc/nixos
sudo nixos-generate-config --no-filesystems --show-hardware-config \
  | sudo tee /etc/nixos/hardware-configuration.nix >/dev/null
sudo tee /etc/nixos/local.nix >/dev/null <<'EOF'
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "laptop";
  my.keyboard = "fr";
  system.stateVersion = "26.05";
}
EOF
sudo nixos-rebuild switch --impure --flake ~/nixos-config#silveros
```

Then open a new terminal: `rebuild` now targets `silveros`.

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

## Hyprland shortcuts (SUPER = Windows key)

| Key | Action |
|---|---|
| SUPER + Enter | terminal (kitty) |
| SUPER + A | launcher (quickshell) |
| SUPER + E | lf in kitty |
| SUPER + B | Brave |
| SUPER + R / K | close / kill the window |
| SUPER + F | fullscreen |
| SUPER + keys 1 to 6 of the number row | workspace 1 to 6 (physical keys: same on AZERTY and QWERTY) |
| SUPER + SHIFT + keys 1 to 6 | move the window |
| SUPER + L | lock |
| SUPER + F1 | lock and suspend |
| SUPER + V | clipboard history (wofi) |
| SUPER + G / Z | pavucontrol / bluetooth |
| Print | screenshot (flameshot) |
| SUPER + ! | quit (hyprshutdown) |
| SUPER + Space | next keyboard layout (the machine's, then fr / be / gb) |

## Choices worth knowing

- Locale `fr_FR.UTF-8`, time zone `Europe/Paris`; keyboard per machine
  (`my.keyboard`, default `fr`), also used for the console and the LUKS prompt.
- No automatic mounting of disks and USB keys: evidence media must never
  be mounted without an explicit action.
- Unfree packages allowed one by one (`modules/core/default.nix`):
  volatility3, claude-code, discord.
- GTK and Qt applications in dark Adwaita (`home/gui/hyprland/env.nix`),
  Papirus Catppuccin icons.
