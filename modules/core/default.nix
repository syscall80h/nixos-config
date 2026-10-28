{
  lib,
  pkgs,
  hostname,
  ...
}:

{
  imports = [
    ./users.nix
    ./upgrade.nix
  ];

  networking.hostName = hostname;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.nixos.distroName = "SilverOS";

  # Unfree packages allowed one by one (everything else stays refused).
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "volatility3"
      "claude-code" # home/claude.nix
      "discord" # home/gui (graphical machine)
    ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  # Allows running non-Nix binaries (wheels downloaded by uv/pip,
  # forensic tools distributed as binaries…).
  programs.nix-ld.enable = true;

  # Required for fish to be usable as a login shell.
  programs.fish.enable = true;

  # Fallback tools, also available to root.
  # vim stays here; shawn's default editor is nvim (home/nvim.nix).
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    unzip
    wget
  ];
}
