{ config, ... }:
let
  host = config.dotfiles.host;
in
{
  services.restic.backups.documents = {
    initialize = true;
    repository = "rclone:dropbox:backups/${host.name}/documents";
    paths = [ "${host.dataRoot}/documents" ];
    passwordFile = config.sops.secrets.restic-password.path;
    rcloneConfigFile = config.sops.secrets.rclone-config.path;

    timerConfig = {
      OnCalendar = "03:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];
    checkOpts = [ "--read-data-subset=5%" ];
  };

  systemd.tmpfiles.rules = [
    "d ${host.dataRoot}/documents 2770 ${host.primaryUser} ${host.mediaGroup} - -"
  ];
}
