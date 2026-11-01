{ pkgs, ... }:
let
  # Image to put in the repo: wallpaper/dfir-wallpaper.png (then git add).
  # While it is missing, hyprpaper stays disabled instead of breaking the build.
  wallpaper = ../../wallpaper/dfir-wallpaper.png;
in
{
  imports = [
    ./easyeffects.nix
    ./hyprland
    ./quickshell
    ./screenshot.nix
    ./virt-manager.nix
  ];

  home.packages = with pkgs; [
    libnotify # notify-send
    keepassxc
    chatterino7
    jellyfin-desktop
    (discord.override {
      commandLineArgs = "--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations";
    })
  ];

  services.hyprsunset = {
    enable = true;
    settings = {
      profile = {
        time = "0:00";
        temperature = 4500;
      };
    };
  };

  services.hyprpaper = {
    enable = builtins.pathExists wallpaper;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = ""; # all monitors
          path = "${wallpaper}";
          fit_mode = "cover";
        }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+alt+t" = "new_tab";
      "ctrl+alt+left" = "previous_tab";
      "ctrl+alt+right" = "next_tab";
    };
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 14;
      package = pkgs.nerd-fonts.caskaydia-cove;
    };
    settings = {
      background_opacity = 0.4;
      confirm_os_window_close = 0;
      remember_window_size = false;

      # Cursor trail: animates the terminal cursor, so it covers nvim without a
      # plugin redrawing the buffer. No custom_shaders here on purpose — the
      # cursor-trail-blaze/lightning shaders hardcode their colours and ignore
      # cursor_trail_color, while the built-in trail honours it.
      #
      # The ms value is how long a cursor must sit still before it is eligible
      # for a trail; 10 still filters nvim's intra-frame redraw churn but lets
      # real navigation animate. A threshold of 1 makes every move animate, so
      # there is no jarring mix of animated and instant jumps.
      cursor_trail = 10;
      cursor_trail_decay = "0.1 0.25";
      cursor_trail_start_threshold = 1;
      cursor_trail_color = "#89b4fa"; # Catppuccin Mocha blue, matches theme.nix accent
      cursor_blink_interval = 0; # blinking fights the trail visually
    };
  };

  programs.mpv = {
    enable = true;
    bindings = {
      WHEEL_DOWN = "add volume -2";
      DOWN = "add volume -2";
      WHEEL_UP = "add volume 2";
      UP = "add volume 2";
      "Shift+LEFT" = "playlist-prev";
      "Shift+RIGHT" = "playlist-next";
    };
    config = {
      profile = "high-quality";
      # ao=pulse # For Discord screenshare
      # gpu-context=wayland # For iGPU usage
      save-position-on-quit = true;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=UseOzonePlatform,TouchpadOverscrollHistoryNavigation"
      "--disable-features=HardwareMediaKeyHandling" # To stop bluetooth headphones to try to interact with videos
    ];
  };

  services.pipewire = {
    enable = true;
    wireplumber = {
      enable = true;
      configs.disable-mic-profile = {
        "monitor.bluez.properties" = {
          "bluez5.hw-volume" = [ ];
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
          ];
        };
      };
    };
  };
}
