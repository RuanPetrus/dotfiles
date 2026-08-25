{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ../../core/host.nix
    ../../core/shared-storage.nix
    ../../services/backup.nix
    ../../services/docker.nix
    ../../services/homepage-dashboard.nix
    ../../services/immich.nix
    ../../services/media.nix
    ../../services/mpd.nix
    ../../services/syncthing.nix
    ../../services/tailscale.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "abiss-watcher";
    lanAddress = "192.168.15.3";
    dataRoot = "/data";
    primaryUser = "ruan";
    accelerationDevices = [ "/dev/dri/renderD128" ];
    accelerationGroups = [
      "video"
      "render"
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
  };

  system.stateVersion = "25.11";
}
