{
  config,
  pkgs,
  flakeDir,
  ...
}:

{
  home.packages = with pkgs; [
    neovim

    # Required by LazyVim: compiling treesitter parsers, search
    gcc
    tree-sitter
    ripgrep # fd is already installed by cli.nix

    # Language servers and formatters (instead of Mason, which does not
    # work as-is on NixOS). Rust and Go: see shells/.
    lua-language-server
    stylua
    nil
    nixfmt
    pyright
    ruff
    vscode-langservers-extracted # JSON
    yaml-language-server
    taplo # TOML
  ];

  home.sessionVariables.EDITOR = "nvim";

  # ~/.config/nvim points straight to the repo's dotfiles/nvim:
  # a change to the Lua config applies without a rebuild.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${flakeDir}/dotfiles/nvim";
}
