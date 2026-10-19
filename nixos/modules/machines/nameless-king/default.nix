{ lib, pkgs, ... }:
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
    ../../services/docker.nix
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
  users.users.ruan.extraGroups = [ "docker" ];

  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  programs.ssh.startAgent = true;

  services.libinput.mouse.accelProfile = "flat";

  home-manager.users.ruan =
    { lib, pkgs, ... }:
    {
      imports = [ ../../users/ruan/desktop.nix ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/id_ruan";
          IdentitiesOnly = true;
          AddKeysToAgent = true;
        };
      };

      home.activation.disablePlasmaAutoSuspend = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file powerdevilrc \
          --group AC \
          --group SuspendAndShutdown \
          --key AutoSuspendAction \
          0
      '';

      home.activation.enableRaisedMaximumVolume = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file plasmaparc \
          --group General \
          --key RaiseMaximumVolume \
          true
      '';

      home.activation.disableMouseAcceleration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        set_flat_mouse_profile() {
          ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
            --file kcminputrc \
            --group Libinput \
            --group "$1" \
            --group "$2" \
            --group "$3" \
            --key PointerAccelerationProfile \
            1
        }

        set_flat_mouse_profile 12994 24 "HS6209 2.4G Wireless Receiver Mouse"
        set_flat_mouse_profile 14139 4229 "CX Wireless mouse -1k dongle Mouse"
        set_flat_mouse_profile 16868 8451 "MCHOSE Ace 60 Pro Mouse"
        set_flat_mouse_profile 4617 3 "libvirtualhid Mouse"
      '';
    };

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  system.stateVersion = "26.05";
}
