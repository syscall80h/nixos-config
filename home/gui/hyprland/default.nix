{ lib, ... }:
{
  imports = [
    ./animation.nix
    ./bind.nix
    ./env.nix
    ./event.nix
    ./hyprlock.nix
    ./misc.nix
    ./packages.nix
    ./window.nix
  ];

  options.vars.hyprland = {
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };
    uwsm = lib.mkOption {
      type = lib.types.str;
      default = "uwsm app -- ";
    };
    launcher = lib.mkOption {
      type = lib.types.str;
      default = "quickshell ipc call launcher toggle";
    };
    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "lf";
    };
  };

  config = {
    # Polkit agent started by systemd with the session (event.nix starts it too)
    services.hyprpolkitagent.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      # Hyprland itself comes from the system (modules/desktop/hyprland.nix)
      package = null;
      portalPackage = null;
      configType = "lua";
      # UWSM (modules/desktop/hyprland.nix) already starts graphical-session.target:
      # home-manager's systemd integration would duplicate it and conflict.
      systemd.enable = false;

      settings.gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];
    };
  };
}
