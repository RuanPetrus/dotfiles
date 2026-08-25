{
  lanAddress,
  ...
}:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "syncthing";
    group = "media";
    dataDir = "/data/syncthing";
    guiAddress = "${lanAddress}:8384";

    # Devices and folders are paired through the UI and must survive rebuilds.
    overrideDevices = false;
    overrideFolders = false;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  users.users.syncthing.homeMode = "2770";

  systemd.tmpfiles.rules = [
    "d /data/syncthing 2770 syncthing media - -"
    "a+ /data/syncthing - - - - g:media:rwx,m::rwx,d:g:media:rwx,d:m::rwx"
  ];
}
