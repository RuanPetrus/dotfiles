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
      };
      ipv6.method = "auto";
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
