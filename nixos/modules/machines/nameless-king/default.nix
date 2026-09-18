{ ... }:
{
  imports = [
    ./disk-config.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ./sunshine.nix
    ../../core/host.nix
    ../../desktops/plasma.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "nameless-king";
    lanAddress = "192.168.15.4";
    primaryUser = "ruan";
  };

  users.users.ruan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcvoAMzd8FNuszc0ysuXmmtNx3NN1X3/66rvORK8qnZ xastroboyx11@gmail.com"
  ];

  home-manager.users.ruan.imports = [ ../../users/ruan/desktop.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
