{ inputs, user, ... }:

{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  wsl = {
    enable = true;
    defaultUser = user;
  };
  
  users.users.${user}.uid = 1001;

  system.stateVersion = "26.05";
}
