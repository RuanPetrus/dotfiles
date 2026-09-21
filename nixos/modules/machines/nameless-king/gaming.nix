{ config, pkgs, ... }:
{
  programs = {
    gamemode = {
      enable = true;
      enableRenice = true;
    };

    gamescope = {
      enable = true;
    };

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      extraPackages = [ pkgs.libcxx ];
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    heroic
    lutris
    mangohud
    qbittorrent
    unrar
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    steam-hardware.enable = true;
    xpadneo.enable = true;
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("com.feralinteractive.GameMode.") === 0 &&
          subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
      }
    });
  '';

  users.users.${config.dotfiles.host.primaryUser}.extraGroups = [ "gamemode" ];
}
