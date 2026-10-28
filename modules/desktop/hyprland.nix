{ lib, pkgs, ... }:

{
  # Hyprland itself (package + portal), launched by UWSM: your shortcuts
  # and your autostart (home/gui/hyprland/) all go through `uwsm app --`.
  # Its configuration is in home/gui/hyprland/.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Text-mode login screen, which launches Hyprland.
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
  };

  # Son
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Authentication for the hyprlock lock screen
  security.pam.services.hyprlock = { };

  # Dark theme for GTK applications (dconf setting)
  programs.dconf.enable = true;

  # Electron/Chromium applications on native Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Deliberately absent: udisks2 / automatic mounting of USB keys and
  # disks. On a forensics workstation, evidence media must never be
  # mounted without an explicit action.
}
