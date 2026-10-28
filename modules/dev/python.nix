{ pkgs, ... }:

{
  # Global Python: many forensic tools install with uv/pip.
  # Rust and Go are in shells/ (nix develop).
  environment.systemPackages = with pkgs; [
    python314
    uv
  ];
}
