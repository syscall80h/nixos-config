{ pkgs, ... }:
let
  # Flameshot's selection overlay assumes its surface is 1:1 with the captured
  # buffer, which is false under fractional scaling: grim hands it the full
  # 1920x1080 frame while the overlay is 1280x720 logical at scale 1.5, so every
  # capture came out as a magnified top-left crop. grim/slurp/satty are native
  # Wayland and get the scale from the compositor, so they are correct by
  # construction.
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard-rs
      jq
      libnotify
    ];
    text = ''
      dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
      mkdir -p "$dir"

      case "''${1:-region}" in
        region)
          geometry=$(slurp -d) || exit 0 # empty selection / Escape
          grim -g "$geometry" -
          ;;
        window)
          grim -g "$(hyprctl activewindow -j |
            jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" -
          ;;
        full)
          grim -
          ;;
        *)
          echo "usage: screenshot [region|window|full]" >&2
          exit 1
          ;;
      esac |
        satty --filename - \
          --output-filename "$dir/%Y-%m-%d_%H-%M-%S.png" \
          --copy-command wl-copy \
          --resize smart \
          --early-exit \
          --initial-tool brush \
          --actions-on-enter save-to-clipboard
    '';
  };
in
{
  # Screenshots: bound to Print / SUPER+Print / SHIFT+Print in
  # home/gui/hyprland/bind.nix. Enter copies to the clipboard and exits, Ctrl+S
  # saves into ~/Pictures/Screenshots.
  home.packages = [ screenshot ];
}
