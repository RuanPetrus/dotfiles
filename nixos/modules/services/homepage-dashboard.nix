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
