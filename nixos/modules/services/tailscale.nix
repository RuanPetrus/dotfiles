{ config, ... }:
let
  host = config.dotfiles.host;
in
{
  imports = [ ./tailscale-client.nix ];

  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=${host.lanAddress}/32" ];
  };
}
