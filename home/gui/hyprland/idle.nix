{ config, ... }:
let
  uwsm = config.vars.hyprland.uwsm;
in
{
  # Idle daemon: locks before any sleep (idle timeout, lid close, manual
  # suspend) via the logind "PrepareForSleep" hook, the same way SUPER+L
  # does, and suspends after 15 minutes of inactivity.
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        before_sleep_cmd = "${uwsm}hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
