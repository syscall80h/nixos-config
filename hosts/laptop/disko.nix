# Disk of the laptop machine: GPT, ESP + LUKS, then btrfs with subvolumes.
# Used twice:
#  - at install time, by the disko command (partitions, formats, mounts on /mnt);
#  - afterwards, by NixOS, which derives fileSystems and the LUKS unlock from it.
{ ... }:

let
  # Shared options. Careful: on btrfs, compress (like nodatacow) applies to
  # the WHOLE filesystem, whichever subvolume it is written on.
  # Only generic options such as noatime apply per mount point.
  opts = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    # Check with `lsblk` from the installer ISO (nvme0n1, sda…).
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # No key file: disko asks for the password when formatting,
            # and it will be asked at every boot.
            settings.allowDiscards = true; # SSD TRIM (see README)
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = opts;
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = opts;
                };
                "@opt" = {
                  mountpoint = "/opt";
                  mountOptions = opts;
                };
                # Nix store kept separate: outside future snapshots of @
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = opts;
                };
                # Logs kept separate: preserved if @ is restored from a snapshot
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = opts;
                };
                # VM images: noatime here; compression is turned off by the NOCOW
                # attribute set below (not possible with a mount option).
                "@vm" = {
                  mountpoint = "/var/lib/libvirt/images";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };

  # NOCOW (chattr +C) on the VM directory: files created inside inherit the
  # attribute, which disables copy-on-write, checksums and compression.
  # Recommended for disk images (avoids fragmentation). Only applies to new
  # files: fine here, the subvolume is empty at install time.
  systemd.tmpfiles.rules = [ "h /var/lib/libvirt/images - - - - +C" ];
}
