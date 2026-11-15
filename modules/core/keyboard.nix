{ ... }:
{
  # Console (TTY, LUKS prompt): same layout as the first XKB layout below.
  console.keyMap = "uk";
  # Load the keymap in the initrd too: otherwise the LUKS passphrase is
  # typed with the default (US) layout at boot.
  console.earlySetup = true;
}
