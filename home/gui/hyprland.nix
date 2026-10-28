{ ... }:
{
  imports = [
    ./hyprland
  ];
  # Polkit agent started by systemd with the session (event.nix starts it too)
  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    # UWSM (modules/desktop/hyprland.nix) already starts graphical-session.target:
    # home-manager's systemd integration would duplicate it and conflict.
    systemd.enable = false;

    settings = {

      # ----------------------------------------------------------------------
      # Gestures
      # ----------------------------------------------------------------------
      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

    };
  };
}
