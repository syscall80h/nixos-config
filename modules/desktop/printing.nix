{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.epson-escpr # most Epson inkjets (Stylus, WorkForce, Expression)
      pkgs.epson-escpr2 # newer Epson inkjets (XP-, ET- EcoTank series)
    ];
  };

  # Network/USB printer auto-discovery (mDNS/Bonjour).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
