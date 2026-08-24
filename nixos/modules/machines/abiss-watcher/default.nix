# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../users/ruan
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Using systemd as boot loader
  boot.loader.systemd-boot.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "abiss-watcher"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

	networking.nameservers = [
	  "1.1.1.1"
	  "8.8.8.8"
	];


  networking.firewall = {
    allowedTCPPorts = [
      8082
      9443
      8080
    ];
    allowedUDPPorts = [
      8211 
    ];
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # programs.firefox.enable = true;

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tmux
    git
    docker-compose
    inputs.opencode.packages.${pkgs.system}.default
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  
  services.homepage-dashboard = {
    enable = true;
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
    services= [
        {
          "Services" = [
            {
              "Jellyfin" = {
                description = "Movie and TV Shows player";
                href = "http://192.168.15.3:8096";
              };
            }
            {
              "Portainer" = {
                description = "Docker management";
                href = "https://192.168.15.3:9443";
              };
	    }
            {
              "Calibre" = {
                description = "Calibre";
                href = "http://192.168.15.3:8080";
              };
            }
          ];
        }
        {
          "Downloaders" = [
            {
              "Transmission" = {
                description = "Transmission";
                href = "http://192.168.15.3:9091";
              };
            }
          ];
        }
        {
          "ArrStack" = [
            {
              "Jelyseer" = {
                description = "JelySeer";
                href = "http://192.168.15.3:5055";
              };
            }
            {
              "Radarr" = {
                description = "Radarr";
                href = "http://192.168.15.3:7878";
              };
            }
            {
              "Sonarr" = {
                description = "Sonarr";
                href = "http://192.168.15.3:8989";
              };
            }
            {
              "Bazarr" = {
                description = "Bazarr";
                href = "http://192.168.15.3:6767";
              };
            }
            {
              "Prowlarr" = {
                description = "Prowlarr";
                href = "http://192.168.15.3:9696";
              };
            }
          ];
        }
        {
          "Info" = [
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
    settings = {
	HOST = "0.0.0.0";
  	PORT = "8082";
    };
    allowedHosts = "localhost:8082,127.0.0.1:8082,192.168.15.3:8082";
  };

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    # vpn = {
    #   enable = true;
    #   # WARNING: This file must _not_ be in the config git directory
    #   # You can usually get this wireguard file from your VPN provider
    #   wgConf = "/data/.secret/wg.conf";
    # };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      # expose.https = {
      #   enable = true;
      #   domainName = "your.domain.com";
      #   acmeMail = "your@email.com"; # Required for ACME-bot
      # };
    };

    transmission = {
      enable = true;
      # vpn.enable = true;
      # peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    # readarr.enable = true;
    sonarr.enable = true;
    seerr.enable = true;
  };

  # 2. Add Jellyfin to necessary groups for hardware access
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  
# Shared group for Samba + Calibre
users.groups.media = {};
users.users.ruan.extraGroups = [ "media" ];

services.samba = {
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

      # Make files created through SMB compatible with Calibre
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

services.calibre-server = {
  enable = true;

  libraries = [
    "/data/Library"
  ];

  host = "0.0.0.0";
  port = 8080;
  openFirewall = true;

  # Same group used by the Samba share
  group = "media";

};


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

