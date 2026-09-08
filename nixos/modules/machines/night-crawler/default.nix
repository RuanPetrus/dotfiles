{
  config,
  ...
}:
let
  notesDirectory = "${config.users.users.ruan.home}/Documents/notes";
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

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "ruan";
    group = "ruan";
    dataDir = notesDirectory;
    configDir = "${config.users.users.ruan.home}/.config/syncthing";

    # Keep device pairing and folder sharing editable through the web UI.
    overrideDevices = false;
    overrideFolders = false;
    settings.folders.notes = {
      label = "Notes";
      path = notesDirectory;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${config.users.users.ruan.home}/Documents 0755 ruan ruan - -"
    "d ${notesDirectory} 0750 ruan ruan - -"
  ];

  home-manager.users.ruan.imports = [ ../../users/ruan/desktop.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
