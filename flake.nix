{
  description = "shawn's NixOS — forensics workstation (WSL + Hyprland machine)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning (hosts/laptop/disko.nix)
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # LazyVim with plugins installed by Nix (home/lazyvim.nix)
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      user = "shawn";
      # Location of the repo: used by the rebuild/update aliases
      # and by the links to dotfiles/ (nvim, hyprland).
      flakeDir = "/home/${user}/nixos-config";

      mkHost =
        hostname:
        let
          # The requested rule: no graphical interface on WSL.
          gui = hostname != "wsl";
          args = {
            inherit
              inputs
              hostname
              gui
              user
              flakeDir
              ;
          };
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = args;
          modules = [
            ./hosts/${hostname}
            ./modules
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = args;
                users.${user}.imports = [
                  ./home
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        wsl = mkHost "wsl";
        laptop = mkHost "laptop";
      };

      # nix develop ~/nixos-config#rust   /   nix develop ~/nixos-config#go
      devShells.${system} = {
        rust = import ./shells/rust.nix { inherit pkgs; };
        go = import ./shells/go.nix { inherit pkgs; };
      };
    };
}
