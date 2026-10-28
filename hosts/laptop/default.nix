{ inputs, pkgs, user, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix # partitions, LUKS, btrfs subvolumes → fileSystems
    ./hardware-configuration.nix # generated with --no-filesystems (see that file)
  ];

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

  # Set to the NixOS version first installed on this machine.
  system.stateVersion = "26.05";
}
