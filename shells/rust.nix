{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
  ];

  # So that rust-analyzer finds the standard library sources
  RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
}
