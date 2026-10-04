{
  config,
  pkgs,
  ...
}:
let
  homeDirectory = config.users.users.ruan.home;
  notesDirectory = "${homeDirectory}/Documents/notes";
in
{
  imports = [
    ./disk-config.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../core/host.nix
    ../../desktops/sway.nix
    ../../hardware/intel-graphics.nix
    ../../services/tailscale-client.nix
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "night-crawler";
    lanAddress = "192.168.0.12";
    primaryUser = "ruan";
  };

  systemd.services.configure-home-wifi = {
    description = "Configure the marombinhas home Wi-Fi profile";
    after = [ "NetworkManager.service" ];
    requires = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      gnugrep
      networkmanager
    ];
    script = ''
      if ! nmcli -g NAME connection show | grep -Fxq marombinhas_5G; then
        exit 0
      fi

      current="$(nmcli -g ipv4.dns,ipv4.dns-priority,ipv4.ignore-auto-dns,ipv6.dns-priority,ipv6.ignore-auto-dns,802-11-wireless.powersave connection show marombinhas_5G)"
      expected=$'192.168.0.1\n-100\nyes\n-100\nyes\ndisable'
      if [[ "$current" == "$expected" ]]; then
        exit 0
      fi

      nmcli connection modify marombinhas_5G \
        ipv4.dns 192.168.0.1 \
        ipv4.dns-priority -100 \
        ipv4.ignore-auto-dns yes \
        ipv6.dns-priority -100 \
        ipv6.ignore-auto-dns yes \
        802-11-wireless.powersave 2
      nmcli connection up marombinhas_5G
    '';
    serviceConfig.Type = "oneshot";
  };

  fileSystems."/mnt/nas" = {
    device = "//192.168.0.10/data";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets.samba-credentials.path}"
      "uid=${toString config.users.users.ruan.uid}"
      "gid=${toString config.users.groups.ruan.gid}"
      "file_mode=0664"
      "dir_mode=0775"
      "vers=3.1.1"
      "_netdev"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=10s"
    ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "ruan";
    group = "ruan";
    dataDir = notesDirectory;
    configDir = "${homeDirectory}/.config/syncthing";

    # Keep device pairing and folder sharing editable through the web UI.
    overrideDevices = false;
    overrideFolders = false;
    settings.folders.notes = {
      label = "Notes";
      path = notesDirectory;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${homeDirectory}/Documents 0755 ruan ruan - -"
    "d ${notesDirectory} 0750 ruan ruan - -"
  ];

  home-manager.users.ruan.imports = [ ../../users/ruan/desktop.nix ];
  home-manager.users.ruan.home.packages = [ pkgs.moonlight-qt ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
