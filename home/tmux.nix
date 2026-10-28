{ ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    escapeTime = 0; # no delay on Escape in nvim
    terminal = "tmux-256color";
  };
}
