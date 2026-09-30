{
  config,
  lib,
  pkgs,
  ...
}:
let
  dashboardAddress = config.dotfiles.host.lanAddress;
in
{
  services.homepage-dashboard.services = lib.mkAfter [
    {
      Machines = [
        {
          Sunshine = {
            description = "Game streaming host";
            href = "https://192.168.0.11:47990";
            icon = "sunshine.png";
          };
        }
        {
          "Wake Nameless King" = {
            description = "Send a Wake-on-LAN packet";
            href = "http://${dashboardAddress}:8083/wake";
            icon = "mdi-power";
          };
        }
      ];
    }
  ];

  systemd.sockets.wake-nameless-king = {
    description = "Wake Nameless King HTTP endpoint";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "8083" ];
    socketConfig.Accept = true;
  };

  systemd.services."wake-nameless-king@" = {
    description = "Send a Wake-on-LAN packet to Nameless King";
    script = ''
      read -r request
      while IFS= read -r line; do
        [[ -z "$line" || "$line" == $'\r' ]] && break
      done

      if [[ "$request" == "GET /wake "* ]]; then
        ${lib.getExe pkgs.wakeonlan} -i 192.168.0.255 30:56:0f:00:63:6f >&2
        printf 'HTTP/1.1 303 See Other\r\nLocation: http://${dashboardAddress}:8082/\r\nConnection: close\r\n\r\n'
      else
        printf 'HTTP/1.1 404 Not Found\r\nConnection: close\r\nContent-Length: 0\r\n\r\n'
      fi
    '';
    serviceConfig = {
      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8083 ];
}
