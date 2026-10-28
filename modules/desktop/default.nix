{ ... }:

{
  imports = [
    ./hyprland.nix
    ./fonts.nix
  ];

  # Catppuccin theme on the system side (TTY console, cursors…)
  catppuccin = {
    enable = true;
    flavor = "mocha"; # same flavor as home/theme.nix
    accent = "blue";
  };
}
