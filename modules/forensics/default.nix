{
  lib,
  pkgs,
  gui,
  user,
  ...
}:

{
  imports = lib.optionals gui [ ./gui.nix ];

  environment.systemPackages = with pkgs; [
    # Disks and images
    sleuthkit # fls, icat, mmls… (the basis of everything else)
    testdisk # testdisk + photorec
    ddrescue # copying damaged disks
    dcfldd # dd with on-the-fly hashing
    dc3dd
    libewf # E01 images: ewfacquire, ewfinfo, ewfmount
    afflib # AFF images
    qemu-utils # qemu-img: conversion VMDK/VHDX/QCOW2 → raw
    ntfs3g
    exfatprogs
    cryptsetup # LUKS
    dislocker # BitLocker

    # Carving and file analysis
    foremost
    scalpel
    binwalk
    bulk_extractor
    yara
    exiftool
    file
    hexyl
    radare2
    p7zip

    # Memory
    volatility3

    # Windows artifacts
    chainsaw # hunting in EVTX
    hayabusa # EVTX timeline
    evtx # evtx_dump
    regripper # registry
    (callPackage ../../pkgs/mftecmd.nix { }) # $MFT, $J, $LogFile (Eric Zimmerman)

    # Hashes
    hashdeep
    ssdeep

    # Network
    tcpdump

    # Utilities
    sqlite # browser histories, mobile databases
    ripgrep
    jq
    pv
  ];

  # Wireshark: dumpcap can capture without root for the "wireshark" group.
  # CLI version (tshark) here; gui.nix switches to the graphical version.
  programs.wireshark = {
    enable = true;
    package = lib.mkDefault pkgs.wireshark-cli;
  };
  users.users.${user}.extraGroups = [ "wireshark" ];
}
