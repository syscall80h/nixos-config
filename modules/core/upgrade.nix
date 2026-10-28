{ inputs, pkgs, ... }:

{
  # Security fixes: on NixOS they arrive through the stable branch
  # nixos-26.05. Every day the system rebuilds with the latest nixpkgs
  # 26.05, from the currently installed config.
  #
  # No automatic reboot: an acquisition or a long processing job must not
  # be interrupted. Kernel updates apply at the next manual reboot.
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L"
    ];
    dates = "daily";
    randomizedDelaySec = "30min";
    persistent = true;
    allowReboot = false;
  };

  systemd.timers.nixos-upgrade.timerConfig.OnBootSec = "5min";

  # Audit: lists the known CVEs of the installed packages.
  #   vulnix --system
  environment.systemPackages = [ pkgs.vulnix ];
}
