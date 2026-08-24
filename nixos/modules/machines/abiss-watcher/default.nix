{
  pkgs,
  ...
}:
{
  _module.args.lanAddress = "192.168.15.3";

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ../../services/docker.nix
    ../../services/homepage-dashboard.nix
    ../../services/media.nix
    ../../system
    ../../users/ruan
  ];

  networking.hostName = "abiss-watcher";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
  };

  system.stateVersion = "25.11";
}
