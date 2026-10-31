{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprshutdown
    wl-clipboard-rs
    pavucontrol
    cliphist
    wofi
    playerctl
    brightnessctl
  ];
}
