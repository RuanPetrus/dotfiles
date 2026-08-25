{
  config,
  ...
}:
let
  host = config.dotfiles.host;
in
{
  services.immich = {
    enable = true;
    host = host.lanAddress;
    port = 2283;
    mediaLocation = "${host.dataRoot}/immich";
    openFirewall = true;
    accelerationDevices = host.accelerationDevices;
  };

  systemd.tmpfiles.rules = [
    "d ${host.dataRoot}/immich 0700 immich immich - -"
  ];

  users.users.immich.extraGroups = host.accelerationGroups;
}
