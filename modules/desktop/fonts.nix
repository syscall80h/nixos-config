{ pkgs, ... }:

{
  # On WSL the font is handled by Windows Terminal: this module is only
  # loaded on the graphical machine.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
}
