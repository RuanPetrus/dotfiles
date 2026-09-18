{ config, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [
      "--accept-dns=false"
      "--hostname=${config.dotfiles.host.name}"
    ];
  };
}
