{ config, lib, ... }:

let
  kb = config.my.keyboard;
  # Same layout, three names: XKB (graphical session), console (TTY, LUKS prompt)
  consoleKeyMap = {
    fr = "fr";
    be = "be-latin1";
    gb = "uk";
  };
in
{
  options.my.keyboard = lib.mkOption {
    type = lib.types.enum [
      "fr"
      "be"
      "gb"
    ];
    default = "fr";
    description = "Main keyboard layout of this machine (XKB name).";
  };

  config = {
    console.keyMap = consoleKeyMap.${kb};
    # Load the keymap in the initrd too: otherwise the LUKS passphrase is
    # typed with the default (US) layout at boot.
    console.earlySetup = true;
  };
}
