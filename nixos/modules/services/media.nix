{
  config,
  inputs,
  ...
}:
let
  host = config.dotfiles.host;
  mediaDir = "${host.dataRoot}/media";
in
{
  imports = [ inputs.nixarr.nixosModules.default ];

  nixarr = {
    enable = true;
    inherit mediaDir;
    stateDir = "${mediaDir}/.state/nixarr";

    jellyfin.enable = true;
    transmission.enable = true;
    bazarr = {
      enable = true;
      settings-sync = {
        sonarr.enable = true;
        radarr.enable = true;
      };
    };
    lidarr.enable = true;
    prowlarr = {
      enable = true;
      settings-sync = {
        enable-nixarr-apps = true;
        indexers = [
          {
            sort_name = "limetorrents";
            name = "LimeTorrents";
            priority = 25;
            fields = {
              definitionFile = "limetorrents";
              "baseSettings.limitsUnit" = 0;
              "torrentBaseSettings.preferMagnetUrl" = false;
              primarydownloadlink = 1;
              fallbackdownloadlink = 0;
              sort = 0;
            };
          }
          {
            sort_name = "nyaa si";
            name = "Nyaa.si";
            priority = 25;
            fields = {
              definitionFile = "nyaasi";
              "baseSettings.limitsUnit" = 0;
              "torrentBaseSettings.preferMagnetUrl" = false;
              prefer_magnet_links = true;
              sonarr_compatibility = false;
              strip_s01 = false;
              radarr_compatibility = false;
              "filter-id" = 0;
              "cat-id" = 0;
              sort = 0;
              type = 1;
            };
          }
          {
            sort_name = "pirate bay";
            name = "The Pirate Bay";
            priority = 25;
            fields = {
              definitionFile = "thepiratebay";
              "baseSettings.limitsUnit" = 0;
              "torrentBaseSettings.preferMagnetUrl" = false;
              apiurl = "apibay.org";
              top100 = 6;
            };
          }
        ];
      };
    };
    radarr = {
      enable = true;
      settings-sync.transmission = {
        enable = true;
        config = {
          priority = 1;
          fields = {
            urlBase = "/transmission/";
            movieCategory = "radarr";
          };
        };
      };
    };
    sonarr = {
      enable = true;
      settings-sync.transmission = {
        enable = true;
        config = {
          priority = 1;
          fields = {
            urlBase = "/transmission/";
            tvCategory = "tv-sonarr";
          };
        };
      };
    };
    recyclarr = {
      enable = true;
      schedule = "daily";
      configuration = {
        radarr.movies = {
          base_url = "http://127.0.0.1:7878";
          api_key = "!env_var RADARR_API_KEY";
          delete_old_custom_formats = true;
          quality_definition.type = "movie";
          quality_profiles = [
            {
              trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
              reset_unmatched_scores.enabled = true;
            }
          ];
          custom_format_groups.add = [
            { trash_id = "f8bf8eab4617f12dfdbd16303d8da245"; } # Golden Rule HD
            { trash_id = "a3ac6af01d78e4f21fcb75f601ac96df"; } # Unwanted Formats
          ];
        };

        sonarr.series = {
          base_url = "http://127.0.0.1:8989";
          api_key = "!env_var SONARR_API_KEY";
          delete_old_custom_formats = true;
          quality_definition.type = "series";
          quality_profiles = [
            {
              trash_id = "72dae194fc92bf828f32cde7744e51a1"; # WEB-1080p
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # Anime Remux-1080p
              reset_unmatched_scores.enabled = true;
            }
          ];
          custom_format_groups.add = [
            { trash_id = "158188097a58d7687dee647e04af0da3"; } # Golden Rule HD
            { trash_id = "74aff4168620ed49dcc67e92b2c2a5b4"; } # Language Profiles
            { trash_id = "85fae4a2294965b75710ef2989c850eb"; } # Streaming Services HD/UHD boost
            { trash_id = "59c3af66780d08332fdc64e68297098f"; } # Unwanted Formats
          ];
        };
      };
    };
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

  users.users = {
    jellyfin.extraGroups = host.accelerationGroups;
    prowlarr.extraGroups = [ host.mediaGroup ];
    recyclarr.extraGroups = [ host.mediaGroup ];
    seerr.extraGroups = [ host.mediaGroup ];
  };

  systemd.tmpfiles.rules = [
    "a+ ${host.dataRoot}/games - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
    "a+ ${host.dataRoot}/Library - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
    "a+ ${mediaDir} - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
    "d ${mediaDir}/.state 2770 root ${host.mediaGroup} - -"
    "d ${mediaDir}/.state/nixarr 2770 root ${host.mediaGroup} - -"
    "a+ ${mediaDir}/library - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
    "a+ ${mediaDir}/torrents - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
  ];

  services = {
    lidarr.settings.auth.required = "DisabledForLocalAddresses";
    prowlarr.settings.auth.required = "DisabledForLocalAddresses";
    radarr.settings.auth.required = "DisabledForLocalAddresses";
    sonarr.settings.auth.required = "DisabledForLocalAddresses";

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          security = "user";
        };

        data = {
          path = host.dataRoot;
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = host.primaryUser;
          "force group" = host.mediaGroup;
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
          "valid users" = host.primaryUser;
        };
      };
    };

    calibre-server = {
      enable = true;
      libraries = [ "${host.dataRoot}/Library" ];
      host = "0.0.0.0";
      port = 8080;
      openFirewall = true;
      group = host.mediaGroup;
    };
  };
}
