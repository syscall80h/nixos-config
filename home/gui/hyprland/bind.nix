{ config, lib, ... }:
# ----------------------------------------------------------------------
# Keybindings
# ----------------------------------------------------------------------
let
  terminal = config.vars.hyprland.terminal;
  uwsm = config.vars.hyprland.uwsm;
  fileManager = config.vars.hyprland.fileManager;
  launcher = config.vars.hyprland.launcher;
  lua = lib.mkLuaInline;

  # Workspaces 1 to 6 on the physical keys of the number row (code:10 = 1 key):
  # works on AZERTY (fr, be) and QWERTY (gb) without depending on the symbols.
  workspaceBinds = lib.concatMap (i: [
    {
      _args = [
        "SUPER + code:${toString (9 + i)}"
        (lua "hl.dsp.focus({ workspace = ${toString i} })")
      ];
    }
    {
      _args = [
        "SUPER + SHIFT + code:${toString (9 + i)}"
        (lua "hl.dsp.window.move({ workspace = ${toString i} })")
      ];
    }
  ]) (lib.range 1 6);
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      {
        _args = [
          "SUPER + exclam"
          (lua ''hl.dsp.exec_cmd("${uwsm}hyprshutdown")'')
        ];
      }
      {
        _args = [
          "SUPER + Return"
          (lua ''hl.dsp.exec_cmd("${uwsm}${terminal}")'')
        ];
      }
      {
        _args = [
          "SUPER + E"
          (lua ''hl.dsp.exec_cmd("${uwsm}${terminal} ${fileManager}")'')
        ];
      }
      {
        _args = [
          "SUPER + B"
          (lua ''hl.dsp.exec_cmd("${uwsm}brave")'')
        ];
      }
      {
        _args = [
          "SUPER + A"
          (lua ''hl.dsp.exec_cmd("${launcher}")'')
        ];
      }
      {
        _args = [
          "SUPER + F"
          (lua ''hl.dsp.window.fullscreen({ action = "toggle" })'')
        ];
      }
      {
        _args = [
          "SUPER + R"
          (lua "hl.dsp.window.close()")
        ];
      }
      {
        _args = [
          "SUPER + K"
          (lua "hl.dsp.window.kill()")
        ];
      }

      {
        _args = [
          "SUPER + F1"
          (lua ''hl.dsp.exec_cmd("hyprlock & systemctl suspend")'')
        ];
      }
      {
        _args = [
          "SUPER + L"
          (lua ''hl.dsp.exec_cmd("${uwsm}hyprlock")'')
        ];
      }
      {
        _args = [
          "SUPER + G"
          (lua ''hl.dsp.exec_cmd("${uwsm}pavucontrol")'')
        ];
      }
      {
        _args = [
          "SUPER + Z"
          (lua ''hl.dsp.exec_cmd("${uwsm}blueman-manager")'')
        ];
      }

      {
        _args = [
          "SUPER + V"
          (lua ''hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy")'')
        ];
      }

      {
        _args = [
          "SUPER + left"
          (lua ''hl.dsp.focus({ direction = "left" })'')
        ];
      }
      {
        _args = [
          "SUPER + right"
          (lua ''hl.dsp.focus({ direction = "right" })'')
        ];
      }
      {
        _args = [
          "SUPER + up"
          (lua ''hl.dsp.focus({ direction = "up" })'')
        ];
      }
      {
        _args = [
          "SUPER + down"
          (lua ''hl.dsp.focus({ direction = "down" })'')
        ];
      }


      {
        _args = [
          "Print"
          (lua ''hl.dsp.exec_cmd("${uwsm}flameshot gui")'')
        ];
      }


      {
        _args = [
          "SUPER + mouse:272"
          (lua "hl.dsp.window.drag()")
          { mouse = true; }
        ];
      }
      {
        _args = [
          "SUPER + mouse:273"
          (lua "hl.dsp.window.resize()")
          { mouse = true; }
        ];
      }

      {
        _args = [
          "XF86AudioRaiseVolume"
          (lua ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioLowerVolume"
          (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioMute"
          (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioMicMute"
          (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86MonBrightnessUp"
          (lua ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86MonBrightnessDown"
          (lua ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86KbdBrightnessUp"
          (lua ''hl.dsp.exec_cmd("brightnessctl -d *kbd_backlight* set 10%+")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86KbdBrightnessDown"
          (lua ''hl.dsp.exec_cmd("brightnessctl -d *kbd_backlight* set 10%-")'')
          {
            locked = true;
            repeating = true;
          }
        ];
      }

      {
        _args = [
          "XF86AudioNext"
          (lua ''hl.dsp.exec_cmd("playerctl next")'')
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPause"
          (lua ''hl.dsp.exec_cmd("playerctl play-pause")'')
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPlay"
          (lua ''hl.dsp.exec_cmd("playerctl play-pause")'')
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPrev"
          (lua ''hl.dsp.exec_cmd("playerctl previous")'')
          { locked = true; }
        ];
      }
    ] ++ workspaceBinds;
  };
}
