{ flakeDir, hostname, ... }:
{
  # Wraps `nix develop` / `nix shell` / `nix-shell` to keep fish
  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      if not set -q IN_NIX_SHELL
        fastfetch
      end
    '';
    shellAliases = {
      # NixOS: `#${hostname}` makes the alias independent of the machine's current name
      rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}#${hostname}";
      # Updates flake.lock (fixes) then rebuilds
      update = "nix flake update --flake ${flakeDir} && sudo nixos-rebuild switch --flake ${flakeDir}#${hostname}";

      # External tools
      lg = "lazygit";
      c = "bat";
      l = "eza -l";
      ll = "eza -la --icons --hyperlink";
      lf = "lfcd";
      f = "fastfetch";
      b = "btop";
      p = "ps aux | rg -v '(ps aux|rg -)' | rg -i";

      # Virtualization
      vm = "virt-manager";
      vls = "virsh list --all"; # all VMs and their state
      vstart = "virsh start"; # vstart win11
      vstop = "virsh shutdown"; # clean shutdown
      vkill = "virsh destroy"; # hard power-off (does not delete the VM)
      vip = "virsh domifaddr"; # VM IP address
      vcon = "virsh console"; # serial console (Linux VMs), Ctrl+] to quit
      vnet = "virsh net-list --all";
      vsnap = "virsh snapshot-create-as"; # vsnap win11 clean
      vsnaps = "virsh snapshot-list"; # vsnaps win11
      vrevert = "virsh snapshot-revert"; # vrevert win11 clean
      vdisks = "ls -lh /var/lib/libvirt/images";

      # GNU tools
      d = "du -haxd1 . | sort -h";
      e = "$EDITOR";
      se = "sudoedit";
      tarc = "tar -czf";
      tarx = "tar -xf";
      lsof = "lsof +D"; # Recursive lookup
      df = "df -Th";
    };
    functions = {
      lfcd = ''
        # Terminal file manager (changing directory on exit)
        # `command` is needed in case `lfcd` is aliased to `lf`.
        # Quotes will cause `cd` to not change directory if `lf` prints nothing to stdout due to an error.
        cd "$(command lf -print-last-dir $argv)"
      '';
    };
    # Theme: catppuccin (home/theme.nix)
  };

  # Prompt: file read straight from the repo (editable without a rebuild)
  programs.oh-my-posh = {
    enable = true;
    enableFishIntegration = true;
    configFile = "${flakeDir}/dotfiles/oh-my-posh/catppuccin_macchiato.json";
  };

  programs.fastfetch.enable = true;
}
