{ config, pkgs, ... }:
let
  cfg = config.dotfiles.router;
in
{
  systemd.tmpfiles.rules = [ "d /run/router-status 0755 root root -" ];

  # Keep privileged health-file reads separate from the unprivileged web server.
  systemd.services.router-status-update = {
    description = "Collect read-only router link status";
    after = [ "systemd-tmpfiles-setup.service" ];
    path = [ pkgs.iproute2 ];
    environment = {
      PPP_INTERFACE = "ppp0";
      DHCP_INTERFACE = cfg.dhcpWanInterface;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 ${./status.py}";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      ReadWritePaths = [ "/run/router-status" ];
      UMask = "0022";
    };
  };

  systemd.timers.router-status-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "10s";
    };
  };

  systemd.services.router-status = {
    description = "Read-only LAN router status page and Homepage API";
    wantedBy = [ "multi-user.target" ];
    wants = [ "router-status-update.service" ];
    after = [ "network.target" "router-status-update.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8084 --bind ${config.dotfiles.host.lanAddress} --directory /run/router-status";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = "5s";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
    };
  };
}
