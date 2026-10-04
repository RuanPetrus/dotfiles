{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.router;
  lanAddress = config.dotfiles.host.lanAddress;
  pppInterface = "ppp0";
in
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
    nameservers = [ "192.168.0.1" ];
    firewall.enable = false;
    nftables = {
      enable = true;
      checkRuleset = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority filter; policy drop;

            iifname "lo" accept
            ct state invalid drop
            ct state { established, related } accept
            meta l4proto { icmp, ipv6-icmp } accept

            iifname "${cfg.dhcpWanInterface}" udp sport 67 udp dport 68 accept
            iifname "${cfg.managementInterface}" tcp dport 22 accept
            iifname "${cfg.lanInterface}" udp sport 68 udp dport 67 accept
            iifname "${cfg.lanInterface}" ip saddr 192.168.0.0/24 udp dport 53 accept
            iifname "${cfg.lanInterface}" ip saddr 192.168.0.0/24 tcp dport { 22, 53, 3000 } accept
          }

          chain forward {
            type filter hook forward priority filter; policy drop;

            ct state invalid drop
            ct state { established, related } accept
            oifname "${pppInterface}" tcp flags syn tcp option maxseg size set rt mtu
            iifname "${cfg.lanInterface}" oifname { "${pppInterface}", "${cfg.dhcpWanInterface}" } accept
          }
        }

        table ip nat {
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "${cfg.lanInterface}" ip saddr 192.168.0.0/24 udp dport 53 redirect to :53
            iifname "${cfg.lanInterface}" ip saddr 192.168.0.0/24 tcp dport 53 redirect to :53
          }

          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname { "${pppInterface}", "${cfg.dhcpWanInterface}" } ip saddr 192.168.0.0/24 masquerade
          }
        }
      '';
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;

    links = {
      "10-management" = {
        matchConfig.PermanentMACAddress = "02:00:00:00:00:01";
        linkConfig.Name = cfg.managementInterface;
      };
      "11-port-0" = {
        matchConfig.PermanentMACAddress = "00:1b:21:72:dc:d0";
        linkConfig.Name = "spare0";
      };
      "12-port-1" = {
        matchConfig.PermanentMACAddress = "00:1b:21:72:dc:d1";
        linkConfig.Name = cfg.lanInterface;
      };
      "13-port-2" = {
        matchConfig.PermanentMACAddress = "00:1b:21:72:dc:d4";
        linkConfig.Name = cfg.dhcpWanInterface;
      };
      "14-port-3" = {
        matchConfig.PermanentMACAddress = "00:1b:21:72:dc:d5";
        linkConfig.Name = cfg.pppoeInterface;
      };
    };

    networks = {
      "05-management" = {
        matchConfig.Name = cfg.managementInterface;
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
        dhcpV4Config = {
          UseDNS = false;
          UseGateway = false;
        };
      };

      "10-lan" = {
        matchConfig.Name = cfg.lanInterface;
        address = [ "${lanAddress}/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCP = "no";
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
      };

      "20-wan-dhcp" = {
        matchConfig.Name = cfg.dhcpWanInterface;
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
        dhcpV4Config = {
          RouteMetric = 200;
          UseDNS = false;
          UseGateway = false;
        };
      };

      "30-wan-pppoe-carrier" = {
        matchConfig.Name = cfg.pppoeInterface;
        networkConfig = {
          DHCP = "no";
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
    "net.ipv6.conf.all.forwarding" = 0;
  };

  services.pppd = lib.mkIf cfg.enablePppoe {
    enable = true;
    peers.primary.config = ''
      plugin pppoe.so ${cfg.pppoeInterface}
      ifname ${pppInterface}
      file ${cfg.pppoeOptionsFile}
      noipdefault
      nodefaultroute
      persist
      maxfail 0
      holdoff 5
      noauth
      mtu 1492
      mru 1492
    '';
  };

  systemd.services.pppd-primary = lib.mkIf cfg.enablePppoe {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
  };
}
