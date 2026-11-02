{ ... }:
{
  # ----------------------------------------------------------------------
  # Window rules
  # ----------------------------------------------------------------------
  wayland.windowManager.hyprland.settings = {
    layer_rule = [
      {
        name = "launcher-blur";
        match = {
          namespace = "launcher";
        };
        blur = true;
        ignore_alpha = 0.3;
      }
      {
        name = "notifications-blur";
        match = {
          namespace = "notifications";
        };
        blur = true;
        ignore_alpha = 0.3;
      }
    ];

    window_rule = [
      {
        name = "rhytia";
        match = {
          class = "Rhytia";
        };
        content = "game";
        no_blur = true;
        no_anim = true;
        no_dim = true;
        opaque = true;
        immediate = true;
      }
      {
        name = "tear_fullscreen";
        match = {
          fullscreen = true;
        };
        content = "game";
        no_blur = true;
        no_anim = true;
        no_dim = true;
        opaque = true;
        immediate = true;
      }
      {
        # Terminal isn't a game: keep blur when it's fullscreened, overriding tear_fullscreen above.
        name = "kitty_fullscreen_blur";
        match = {
          class = "kitty";
          fullscreen = true;
        };
        content = "none";
        no_blur = false;
        no_anim = false;
        no_dim = false;
        opaque = false;
        immediate = false;
      }
      {
        name = "steam";
        match = {
          class = "steam";
        };
        content = "game";
        workspace = "4";
        no_blur = true;
        no_dim = true;
        opaque = true;
        immediate = true;
        render_unfocused = true;
      }
      {
        name = "RetroArch";
        match = {
          class = "com.libretro.RetroArch";
        };
        no_blur = true;
        no_dim = true;
        opaque = true;
        immediate = true;
      }
      {
        name = "steam-games";
        match = {
          initial_class = "steam_app_.*";
        };
        content = "game";
        workspace = "1";
        no_blur = true;
        no_anim = true;
        no_dim = true;
        opaque = true;
        immediate = true;
        render_unfocused = true;
      }
      {
        name = "osu";
        match = {
          class = "osu!";
        };
        content = "game";
        workspace = "1";
        no_blur = true;
        no_anim = true;
        no_dim = true;
        opaque = true;
        immediate = true;
      }
      {
        name = "parsec";
        match = {
          class = "parsecd";
        };
        content = "game";
        no_blur = true;
        no_dim = true;
        opaque = true;
      }
      {
        name = "discord";
        match = {
          class = "discord";
        };
        workspace = "2";
      }
      {
        name = "bongocat";
        match = {
          title = "BongoCat";
        };
        float = true;
        workspace = "2";
      }
      {
        name = "satty";
        match = {
          class = "com.gabm.satty";
        };
        float = true;
      }
    ];
  };
}
