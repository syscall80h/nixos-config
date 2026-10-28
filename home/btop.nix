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
}
