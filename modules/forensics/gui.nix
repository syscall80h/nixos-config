{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    autopsy
    ghidra
  ];

  programs.wireshark.package = pkgs.wireshark;
}
