{
  networking = {
    networkmanager.enable = true;

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
