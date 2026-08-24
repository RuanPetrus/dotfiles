{
  inputs,
  ...
}:
{
  imports = [ inputs.nixarr.nixosModules.default ];

  nixarr = {
    enable = true;
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    jellyfin.enable = true;
    transmission.enable = true;
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    seerr.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      5055 # Seerr
      6767 # Bazarr
      7878 # Radarr
      8096 # Jellyfin
      8686 # Lidarr
      8989 # Sonarr
      9091 # Transmission web UI
      9696 # Prowlarr
      51413 # Transmission peers
    ];
    allowedUDPPorts = [ 51413 ];
  };

  users = {
    groups.media = { };
    users = {
      jellyfin.extraGroups = [
        "video"
        "render"
      ];
      prowlarr.extraGroups = [ "media" ];
      ruan.extraGroups = [ "media" ];
      seerr.extraGroups = [ "media" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /data 2775 root media - -"
    "a+ /data - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
    "a+ /data/games - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
    "a+ /data/Library - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
    "a+ /data/media - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
    "d /data/media/.state 2770 root media - -"
    "d /data/media/.state/nixarr 2770 root media - -"
    "a+ /data/media/library - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
    "a+ /data/media/torrents - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
  ];

  services = {
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          security = "user";
        };

        data = {
          path = "/data";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "ruan";
          "force group" = "media";
          "create mask" = "0664";
          "directory mask" = "2775";
          "force create mode" = "0660";
          "force directory mode" = "2770";
        };

        "palworld-config" = {
          path = "/srv/palworld-server/compose/Saved/";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "ruan";
        };
      };
    };

    calibre-server = {
      enable = true;
      libraries = [ "/data/Library" ];
      host = "0.0.0.0";
      port = 8080;
      openFirewall = true;
      group = "media";
    };
  };
}
