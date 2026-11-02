{ flakeDir, host, ... }:
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
      # fastfetch only in a normal terminal, not inside nix-shell / nix develop
      if not set -q IN_NIX_SHELL
        fastfetch
      end
    '';
    shellAliases = {
      # `#${host}` selects the configuration whatever the machine's name.
      # --impure: silveros reads /etc/nixos/local.nix, outside the repo.
      rebuild = "sudo nixos-rebuild switch --impure --flake ${flakeDir}#${host}";
      # Updates flake.lock (fixes) then rebuilds
      update = "nix flake update --flake ${flakeDir} && sudo nixos-rebuild switch --impure --flake ${flakeDir}#${host}";

      erase = "sudo nix-collect-garbage -d
  sudo nixos-rebuild switch --impure --flake ~/nixos-config#silveros";
      # External tools
      lg = "lazygit";
      cl = "claude";
      c = "bat";
      l = "eza -l";
      ll = "eza -la --icons --hyperlink";
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
