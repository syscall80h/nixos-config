#!/usr/bin/env bash
# Install SilverOS (the "silveros" configuration) from the NixOS ISO:
# partition (disko), install, set the user password, copy the repo.
#
# Usage (as root, from the repo folder on the ISO):
#   sudo ./install.sh [disk]        e.g. sudo ./install.sh sda
#
# WARNING: the chosen disk is COMPLETELY ERASED.
set -euo pipefail

HOST="silveros"
USER_NAME="shawn"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "error: $*" >&2; exit 1; }

# --- Checks -----------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || die "run as root (sudo ./install.sh)"
[ -d /sys/firmware/efi ] || die "not booted in UEFI mode (systemd-boot needs UEFI)"
[ -f "$REPO_DIR/flake.nix" ] || die "flake.nix not found next to this script"
ping -c1 -W3 github.com >/dev/null 2>&1 || die "no network (flake inputs are downloaded from GitHub)"

export NIX_CONFIG="experimental-features = nix-command flakes"

# --- Keyboard (loaded NOW so the LUKS passphrase is typed with it) -------------
# Hardcoded in the repo (modules/core/keyboard.nix): SUPER + Space cycles
# through Qwerty UK, azerty FR, azerty BE. UK is first, so it's what the
# installer loads here.
loadkeys uk

# --- Disk choice ------------------------------------------------------------
echo
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E 'NAME|disk'
echo

DISK="${1:-}"
if [ -z "$DISK" ]; then
  read -rp "Disk to ERASE (e.g. sda or nvme0n1): " DISK
fi
# Accept both "sda" and "/dev/sda"
DISK="/dev/${DISK#/dev/}"
[ -b "$DISK" ] || die "$DISK is not a block device (see the list above)"
# disko needs the WHOLE disk (sda, nvme0n1), not a partition (sda1, nvme0n1p1)
if [ "$(lsblk -dno TYPE "$DISK")" != "disk" ]; then
  PARENT="$(lsblk -no PKNAME "$DISK" | head -n1)"
  die "$DISK is a partition, not a whole disk${PARENT:+ (did you mean /dev/$PARENT?)}"
fi

echo
lsblk "$DISK"
echo
echo "ALL DATA ON $DISK WILL BE DESTROYED."
read -rp "Type the disk again to confirm: " CONFIRM
[ "/dev/${CONFIRM#/dev/}" = "$DISK" ] || die "confirmation does not match, aborting"

cd "$REPO_DIR"
# A flake only sees git-tracked files
if [ ! -d .git ]; then git init -q -b main; fi
git add -A

# --- 1. Partition, encrypt (LUKS passphrase asked here), format, mount on /mnt -
# Leftovers from a previous attempt would make disko fail: unmount and close them
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true

# disko runs on a copy with the chosen disk: the repo is not modified
DISKO_FILE="$(mktemp --suffix=.nix)"
sed -E "s|(device = \")/dev/[^\"]+(\";)|\1${DISK}\2|" "hosts/$HOST/disko.nix" > "$DISKO_FILE"
grep -q "device = \"$DISK\";" "$DISKO_FILE" || die "could not set the device for disko"
nix run github:nix-community/disko/latest -- --mode destroy,format,mount "$DISKO_FILE"

# --- 2. Install ---------------------------------------------------------------
# hostname, stateVersion and hardware-configuration.nix are tracked in the
# repo (hosts/silveros/): nothing left to write outside git.
nixos-install --flake ".#$HOST" --no-root-passwd

# --- 3. User password (the config defines none) -----------------------------------
echo
echo "Set the password for $USER_NAME:"
until nixos-enter --root /mnt -c "passwd $USER_NAME"; do
  echo "Try again."
done

# --- 4. Copy the repo to the new system -------------------------------------------
cp -r "$REPO_DIR" "/mnt/home/$USER_NAME/nixos-config"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME/nixos-config"

echo
echo "Done. Run 'reboot', remove the USB key, then enter the LUKS passphrase."
