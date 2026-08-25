{
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../../secrets/abiss-watcher.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets.ruan-password-hash.neededForUsers = true;
    secrets.restic-password.mode = "0400";
    secrets.rclone-config.mode = "0400";
  };

  users = {
    mutableUsers = false;
    users.ruan.hashedPasswordFile = config.sops.secrets.ruan-password-hash.path;
  };
}
