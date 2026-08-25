{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--accept-dns=false"
      "--advertise-routes=192.168.15.3/32"
      "--hostname=abiss-watcher"
    ];
  };
}
