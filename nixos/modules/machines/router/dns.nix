{ config, ... }:
let
  lanAddress = config.dotfiles.host.lanAddress;
  lanInterface = config.dotfiles.router.lanInterface;
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = lanInterface;
      bind-dynamic = true;
      port = 0;
      dhcp-authoritative = true;
      dhcp-range = "192.168.0.100,192.168.0.254,255.255.255.0,12h";
      dhcp-option = [
        "option:router,${lanAddress}"
        "option:dns-server,${lanAddress}"
      ];
    };
  };

  services.adguardhome = {
    enable = true;
    host = lanAddress;
    port = 3000;
    openFirewall = false;
    mutableSettings = true;
    settings = {
      dns = {
        bind_hosts = [ lanAddress ];
        port = 53;
        allowed_clients = [ "192.168.0.0/24" ];
        upstream_dns = [ "127.0.0.1:5335" ];
        fallback_dns = [ ];
        bootstrap_dns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        cache_size = 16777216;
        cache_optimistic = true;
        ratelimit = 100;
        refuse_any = true;
        use_private_ptr_resolvers = false;
        local_ptr_upstreams = [ ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        blocking_mode = "default";
        filters_update_interval = 24;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
      ];
      querylog = {
        enabled = true;
        file_enabled = true;
        interval = "168h";
      };
      statistics = {
        enabled = true;
        interval = "168h";
      };
    };
  };

  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings.server = {
      interface = [ "127.0.0.1@5335" ];
      access-control = [ "127.0.0.0/8 allow" ];
      do-ip4 = true;
      do-ip6 = false;
      harden-dnssec-stripped = true;
      hide-identity = true;
      hide-version = true;
      prefetch = true;
      qname-minimisation = true;
    };
  };

  systemd.services.adguardhome = {
    after = [ "unbound.service" ];
    wants = [ "unbound.service" ];
  };
}
