{ inputs, pkgs, user, ... }:

let
  # Settings specific to each machine, written by install.sh and kept out of
  # git: hardware-configuration.nix, hostname, keyboard, stateVersion.
  # Reading a file outside the repo needs `--impure` (rebuild/update aliases
  # and the automatic upgrade already pass it).
  localConfig = /etc/nixos/local.nix;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix # partitions, LUKS, btrfs subvolumes → fileSystems
  ]
  ++ (
    if builtins.pathExists localConfig then
      [ localConfig ]
    else
      # Also reached without --impure: pure evaluation cannot see /etc
      throw "/etc/nixos/local.nix not found. Forgot --impure? (the rebuild alias passes it). Otherwise create it: see README, 'Migrating an existing machine'."
  );

  # Compressed swap in RAM only (no swap on disk)
  zramSwap.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;

  # Intel GPU: hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  users.users.${user}.extraGroups = [
    "networkmanager"
    "video"
  ];
}
