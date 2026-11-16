{
  config,
  ...
}:
let
  lanAddress = config.dotfiles.host.lanAddress;
in
{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "localhost:8082,127.0.0.1:8082,${lanAddress}:8082";

    settings = {
      HOST = "0.0.0.0";
      PORT = "8082";
    };

    widgets = [
      {
        resources = {
          label = "Hardware";
          cpu = true;
          memory = true;
          cputemp = true;
          tempmin = 0;
          tempmax = 100;
          units = "metric";
          uptime = true;
          disk = "/";
          network = true;
          refresh = 5000;
        };
      }
    ];

    services = [
      {
        Network = [
          {
            "Router status" = {
              icon = "mdi-router-network";
              href = "http://192.168.0.1:8084";
              description = "Active provider and PPPoE / DHCP link health";
              widget = {
                type = "customapi";
                url = "http://192.168.0.1:8084/status.json";
                refreshInterval = 10000;
                mappings = [
                  {
                    field = "active";
                    label = "Active link";
                    format = "text";
                  }
                  {
                    field = "pppoe.status";
                    label = "PPPoE";
                    format = "text";
                  }
                  {
                    field = "dhcp.status";
                    label = "DHCP";
                    format = "text";
                  }
                ];
              };
            };
          }
          {
            "AdGuard Home" = {
              icon = "adguard-home.png";
              href = "http://192.168.0.1:3000";
              description = "Router DNS filtering and query logs";
            };
          }
          {
            "TP-Link AP (.106)" = {
              icon = "mdi-access-point";
              href = "http://192.168.0.106";
              description = "TP-Link access point administration";
            };
          }
          {
            "TP-Link AP (.2)" = {
              icon = "mdi-access-point";
              href = "http://192.168.0.2";
              description = "TP-Link access point administration";
            };
          }
        ];
      }
      {
        Services = [
          {
            Jellyfin = {
              description = "Movie and TV Shows player";
              href = "http://${lanAddress}:8096";
            };
          }
          {
            Portainer = {
              description = "Docker management";
              href = "https://${lanAddress}:9443";
            };
          }
          {
            Immich = {
              description = "Photo and video library";
              href = "http://${lanAddress}:2283";
            };
          }
          {
            Calibre = {
              description = "Calibre";
              href = "http://${lanAddress}:8080";
            };
          }
          {
            Syncthing = {
              description = "File synchronization";
              href = "http://${lanAddress}:8384";
            };
          }
          {
            OpenCode = {
              description = "AI machine management";
              href = "http://${lanAddress}:4096";
            };
          }
        ];
      }
      {
        Downloaders = [
          {
            Transmission = {
              description = "Transmission";
              href = "http://${lanAddress}:9091";
            };
          }
        ];
      }
      {
        ArrStack = [
          {
            Jelyseer = {
              description = "JelySeer";
              href = "http://${lanAddress}:5055";
            };
          }
          {
            Radarr = {
              description = "Radarr";
              href = "http://${lanAddress}:7878";
            };
          }
          {
            Sonarr = {
              description = "Sonarr";
              href = "http://${lanAddress}:8989";
            };
          }
          {
            Lidarr = {
              description = "Lidarr";
              href = "http://${lanAddress}:8686";
            };
          }
          {
            Bazarr = {
              description = "Bazarr";
              href = "http://${lanAddress}:6767";
            };
          }
          {
            Prowlarr = {
              description = "Prowlarr";
              href = "http://${lanAddress}:9696";
            };
          }
        ];
      }
      {
        Info = [
          {
            "Public IP" = {
              description = "IPv4";
              widget = {
                type = "customapi";
                url = "https://api.ipify.org?format=json";
                refreshInterval = 60000;
                mappings = [
                  {
                    field = "ip";
                    label = "IPv4";
                    format = "text";
                  }
                ];
              };
            };
          }
        ];
      }
    ];
  };
}
