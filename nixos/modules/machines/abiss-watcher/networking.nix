{
  networking = {
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

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
