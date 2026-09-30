{ ... }:
{
  imports = [
    ./disk-config.nix
    ./gaming.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./secrets.nix
    ./sunshine.nix
    ../../core/host.nix
    ../../desktops/plasma.nix
    ../../services/tailscale-client.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "nameless-king";
    lanAddress = "192.168.0.11";
    primaryUser = "ruan";
  };

  users.users.ruan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcvoAMzd8FNuszc0ysuXmmtNx3NN1X3/66rvORK8qnZ xastroboyx11@gmail.com"
  ];

  home-manager.users.ruan =
    { lib, pkgs, ... }:
    {
      imports = [ ../../users/ruan/desktop.nix ];

      home.activation.disablePlasmaAutoSuspend = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file powerdevilrc \
          --group AC \
          --group SuspendAndShutdown \
          --key AutoSuspendAction \
          0
      '';
    };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
