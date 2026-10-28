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
      fastfetch
    '';
    shellAliases = {
      # NixOS: `#${hostname}` makes the alias independent of the machine's current name
      rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}#${hostname}";
      # Updates flake.lock (fixes) then rebuilds
      update = "nix flake update --flake ${flakeDir} && sudo nixos-rebuild switch --flake ${flakeDir}#${hostname}";

      # External tools
      lg = "lazygit";
      cl = "claude";
      c = "bat";
      l = "eza -l";
      ll = "eza -la";
      lf = "lfcd";
      f = "fastfetch";
      b = "btop";
      p = "ps aux | rg -v '(ps aux|rg -)' | rg -i";

      # Openssl
      openssl_chain = "openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -text -noout"; # To be piped (ex: cat)
      openssl_connect = "openssl s_client -showcerts -connect"; # ip:port

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
