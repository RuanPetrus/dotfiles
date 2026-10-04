{ config, ... }:
{
  networking.firewall.allowedUDPPorts = [ 34197 ];

  networking.networkmanager.ensureProfiles.profiles.nameless-king-wired = {
    connection = {
      id = "nameless-king-wired";
      type = "ethernet";
      interface-name = "enp5s0";
      autoconnect = true;
      autoconnect-priority = 100;
    };
    # NetworkManager's keyfile format represents the magic-packet flag as 64.
    ethernet.wake-on-lan = 64;
    ipv4 = {
      method = "manual";
      address1 = "${config.dotfiles.host.lanAddress}/24,192.168.0.1";
      dns = "192.168.0.1;";
      dns-priority = -100;
      ignore-auto-dns = true;
    };
    ipv6 = {
      method = "auto";
      dns-priority = -100;
      ignore-auto-dns = true;
    };
  };
}
