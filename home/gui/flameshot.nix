{ ... }:
{
  # Screenshots: `flameshot gui` is bound to Print (home/gui/hyprland/bind.nix).
  # The package is built with grim support, which wlroots compositors need.
  services.flameshot = {
    enable = true;
    settings.General = {
      useGrimAdapter = true;
      disabledGrimWarning = true;
      showStartupLaunchMessage = false;
    };
  };
}
