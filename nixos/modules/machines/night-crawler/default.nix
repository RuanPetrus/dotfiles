{
  config,
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
    ../../system
    ../../users/ruan
  ];

  dotfiles.host = {
    name = "night-crawler";
    primaryUser = "ruan";
  };

  fileSystems."/mnt/nas" = {
    device = "//192.168.15.3/data";
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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
