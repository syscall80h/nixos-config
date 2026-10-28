#!/usr/bin/env bash
# Install the "laptop" host from the NixOS ISO: partition (disko), generate the
# hardware config, install, set the user password, copy the repo.
#
# Usage (as root, from the repo folder on the ISO):
#   sudo ./install.sh [/dev/nvme0n1]
#
# WARNING: the chosen disk is COMPLETELY ERASED.
set -euo pipefail

HOST="laptop"
USER_NAME="shawn"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- Checks -----------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || die "run as root (sudo ./install.sh)"
[ -d /sys/firmware/efi ] || die "not booted in UEFI mode (systemd-boot needs UEFI)"
[ -f "$REPO_DIR/flake.nix" ] || die "flake.nix not found next to this script"
ping -c1 -W3 github.com >/dev/null 2>&1 || die "no network (flake inputs are downloaded from GitHub)"

export NIX_CONFIG="experimental-features = nix-command flakes"

# --- Disk choice ------------------------------------------------------------
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E 'NAME|disk'
echo

DISK="${1:-}"
if [ -z "$DISK" ]; then
  read -rp "Disk to ERASE (e.g. /dev/nvme0n1): " DISK
fi
[ -b "$DISK" ] || die "$DISK is not a block device"

echo
lsblk "$DISK"
echo
echo "ALL DATA ON $DISK WILL BE DESTROYED."
read -rp "Type the disk path again to confirm: " CONFIRM
[ "$CONFIRM" = "$DISK" ] || die "confirmation does not match, aborting"

# --- Work on a copy so the repo is only changed where needed ------------------
cd "$REPO_DIR"

# Set the disk in disko.nix (the device line is the only one matching /dev/...)
sed -i -E "s|(device = \")/dev/[^\"]+(\";)|\1${DISK}\2|" hosts/$HOST/disko.nix
grep -q "device = \"$DISK\";" hosts/$HOST/disko.nix || die "could not set the device in disko.nix"

# A flake only sees git-tracked files
if [ ! -d .git ]; then git init -q -b main; fi
git add -A

# --- 1. Partition, encrypt (LUKS password asked here), format, mount on /mnt ---
nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount hosts/$HOST/disko.nix

# --- 2. Hardware config WITHOUT filesystems (disko describes them) --------------
nixos-generate-config --no-filesystems --show-hardware-config --root /mnt \
  > hosts/$HOST/hardware-configuration.nix
git add -A

# --- 3. Install -----------------------------------------------------------------
nixos-install --flake ".#$HOST" --no-root-passwd

# --- 4. User password (the config defines none) ---------------------------------
echo
echo "Set the password for $USER_NAME:"
until nixos-enter --root /mnt -c "passwd $USER_NAME"; do
  echo "Try again."
done

# --- 5. Copy the repo to the new system -------------------------------------------
cp -r "$REPO_DIR" "/mnt/home/$USER_NAME/nixos-config"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME/nixos-config"

echo
echo "Done. Run 'reboot', remove the USB key, then enter the LUKS password."
