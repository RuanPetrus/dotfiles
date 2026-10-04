{ config, ... }:
{
  networking = {
    networkmanager.enable = true;
    networkmanager.ensureProfiles.profiles.abiss-watcher-wired = {
      connection = {
        id = "abiss-watcher-wired";
        type = "ethernet";
        autoconnect = true;
        autoconnect-priority = 100;
      };
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

    firewall = {
      allowedTCPPorts = [
        8080
        8082
        9443
      ];
      allowedUDPPorts = [ 8211 ];
    };
  };
}
