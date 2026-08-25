{
  imports = [
    ./disk-config.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../core/host.nix
    ../../desktops/sway.nix
    ../../hardware/intel-graphics.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "night-crawler";
    primaryUser = "ruan";
  };

  home-manager.users.ruan.imports = [ ../../users/ruan/desktop.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
