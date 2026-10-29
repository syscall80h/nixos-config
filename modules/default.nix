{ lib, gui, ... }:

{
  imports = [
    ./core
    ./dev/python.nix
    ./virtualisation/docker.nix
    ./forensics
  ]
  # Hyprland and the whole graphical environment: only if gui = true
  ++ lib.optionals gui [
    ./desktop
    ./virtualisation/libvirt.nix # not on WSL
  ];
}
