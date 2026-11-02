{ ... }:
{
  # Theme: catppuccin (home/theme.nix)
  programs.btop = {
    enable = true;
    settings = {
      update_ms = 500;
      proc_sorting = "cpu direct";
    };
  };

  # Memory-sorted variant, launched by clicking the RAM stat in the bar
  # (home/gui/quickshell/qml/bar/Bar.qml).
  xdg.configFile."btop/mem.conf".text = ''
    color_theme = "catppuccin_mocha.theme"
    proc_sorting = "memory"
    update_ms = 500
  '';
}
