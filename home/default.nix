{ lib, gui, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./theme.nix
    ./fish.nix
    ./tmux.nix
    ./yazi.nix
    ./lf.nix
    ./lazyvim.nix
    ./git.nix
    ./vars.nix
    ./btop.nix
    ./claude.nix
    ./packages.nix
    ./ssh.nix
  ]
  # Hyprland desktop, quickshell, graphical apps: only if gui = true
  ++ lib.optionals gui [ ./gui ];

  programs.bat.enable = true; # theme: catppuccin (home/theme.nix)
}
