{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/dark-lurker.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      ruan-password-hash.neededForUsers = true;
      id_ruan = {
        owner = "ruan";
        mode = "0400";
        path = "/home/ruan/.ssh/id_ruan";
      };
      samba-credentials = {
        mode = "0400";
        restartUnits = [ "mnt-nas.mount" ];
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /home/ruan/.ssh 0700 ruan ruan - -" ];

  users = {
    mutableUsers = false;
    users.ruan.hashedPasswordFile = config.sops.secrets.ruan-password-hash.path;
  };
}
