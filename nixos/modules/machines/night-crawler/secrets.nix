{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/night-crawler.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      ruan-password-hash.neededForUsers = true;
      samba-credentials = {
        mode = "0400";
        restartUnits = [ "mnt-nas.mount" ];
      };
    };
  };

  users = {
    mutableUsers = false;
    users.ruan.hashedPasswordFile = config.sops.secrets.ruan-password-hash.path;
  };
}
