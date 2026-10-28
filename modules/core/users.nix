{ pkgs, user, ... }:

{
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };
}
