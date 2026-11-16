{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;
  };

  environment.systemPackages = [ pkgs.lutris ];
  hardware.steam-hardware.enable = true;
}
