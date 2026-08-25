{
  config,
  ...
}:
let
  host = config.dotfiles.host;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "syncthing";
    group = host.mediaGroup;
    dataDir = "${host.dataRoot}/syncthing";
    guiAddress = "${host.lanAddress}:8384";

    # Devices and folders are paired through the UI and must survive rebuilds.
    overrideDevices = false;
    overrideFolders = false;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  users.users.syncthing.homeMode = "2770";

  systemd.tmpfiles.rules = [
    "d ${host.dataRoot}/syncthing 2770 syncthing ${host.mediaGroup} - -"
    "a+ ${host.dataRoot}/syncthing - - - - g:${host.mediaGroup}:rwx,m::rwx,d:g:${host.mediaGroup}:rwx,d:m::rwx"
  ];
}
