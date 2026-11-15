{ inputs, pkgs, user, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix # partitions, LUKS, btrfs subvolumes → fileSystems
    ./hardware-configuration.nix
  ];

  networking.hostName = "silveros";

  # NixOS version this machine was installed with: never change it.
  system.stateVersion = "26.05";

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

  # Suspend on lid close, whether on battery, on AC, or docked.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  users.users.${user}.extraGroups = [
    "networkmanager"
    "video"
  ];
}
