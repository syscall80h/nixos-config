{ gui, ... }:

{
  # Catppuccin Mocha applied automatically to every enabled program that
  # has a theme: fish, tmux, btop, bat, kitty, hyprland, hyprlock…
  # This is the only place to choose the flavor: do not repeat it in the
  # programs' files (definition conflicts otherwise).
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    # Neovim is themed by its own config (dotfiles/nvim).
    nvim.enable = false;

    # eza theme
    eza.enable = false;

    # Papirus icons in Catppuccin colors, graphical machines only.
    gtk.icon.enable = gui;
  };

  xdg.configFile."eza/theme.yml".source = ../dotfiles/eza/theme.yml;
}
