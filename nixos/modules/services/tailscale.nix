{ config, ... }:
let
  host = config.dotfiles.host;
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--accept-dns=false"
      "--advertise-routes=${host.lanAddress}/32"
      "--hostname=${host.name}"
    ];
  };
}
