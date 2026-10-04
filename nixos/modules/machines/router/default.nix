{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dns.nix
    ./hardware-configuration.nix
    ./link-balancer.nix
    ./networking.nix
    ./secrets.nix
    ../../core/host.nix
  ];

  options.dotfiles.router = {
    lanInterface = lib.mkOption {
      type = lib.types.str;
      default = "lan0";
      description = "Interface connected to the LAN switch.";
    };

    dhcpWanInterface = lib.mkOption {
      type = lib.types.str;
      default = "wan-backup";
      description = "Backup WAN interface configured by DHCP.";
    };

    pppoeInterface = lib.mkOption {
      type = lib.types.str;
      default = "wan-pppoe";
      description = "Ethernet interface carrying the primary PPPoE WAN.";
    };

    managementInterface = lib.mkOption {
      type = lib.types.str;
      default = "management0";
      description = "Private QEMU user-network interface used for host administration.";
    };

    enablePppoe = lib.mkEnableOption "the primary PPPoE WAN";

    pppoeOptionsFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/router-pppoe-options";
      description = "Runtime-only pppd options file containing the PPPoE username and password.";
    };
  };

  config = {
    dotfiles.host = {
      name = "router";
      lanAddress = "192.168.0.1";
      primaryUser = "ruan";
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    time.timeZone = "America/Sao_Paulo";
    i18n.defaultLocale = "en_US.UTF-8";

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    environment.systemPackages = with pkgs; [
      conntrack-tools
      ethtool
      git
      iproute2
      nftables
      ppp
      socat
      tcpdump
      tmux
      vim
    ];

    services.openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/var/lib/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    systemd.tmpfiles.rules = [ "d /var/lib/ssh 0700 root root -" ];

    users = {
      mutableUsers = false;
      users.ruan = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZLaiIK3Q+dwdxPCYGAWspqzATww2fRPqGglLJoi6uX opencode-machine-manager@abiss-watcher"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcvoAMzd8FNuszc0ysuXmmtNx3NN1X3/66rvORK8qnZ xastroboyx11@gmail.com"
        ];
      };
    };

    security.sudo.wheelNeedsPassword = false;
    system.stateVersion = "25.11";
  };
}
