{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "localhost:8082,127.0.0.1:8082,192.168.15.3:8082";

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
              href = "http://192.168.15.3:8096";
            };
          }
          {
            Portainer = {
              description = "Docker management";
              href = "https://192.168.15.3:9443";
            };
          }
          {
            Calibre = {
              description = "Calibre";
              href = "http://192.168.15.3:8080";
            };
          }
        ];
      }
      {
        Downloaders = [
          {
            Transmission = {
              description = "Transmission";
              href = "http://192.168.15.3:9091";
            };
          }
        ];
      }
      {
        ArrStack = [
          {
            Jelyseer = {
              description = "JelySeer";
              href = "http://192.168.15.3:5055";
            };
          }
          {
            Radarr = {
              description = "Radarr";
              href = "http://192.168.15.3:7878";
            };
          }
          {
            Sonarr = {
              description = "Sonarr";
              href = "http://192.168.15.3:8989";
            };
          }
          {
            Bazarr = {
              description = "Bazarr";
              href = "http://192.168.15.3:6767";
            };
          }
          {
            Prowlarr = {
              description = "Prowlarr";
              href = "http://192.168.15.3:9696";
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
