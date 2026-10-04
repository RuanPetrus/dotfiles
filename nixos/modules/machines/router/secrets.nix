{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/router.yaml;
    age.sshKeyPaths = [ "/var/lib/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets.pppoe-username = { };
    secrets.pppoe-password = { };

    templates."router-pppoe-options" = {
      content = ''
        user "${config.sops.placeholder.pppoe-username}"
        password "${config.sops.placeholder.pppoe-password}"
      '';
      owner = "root";
      mode = "0400";
    };
  };

  dotfiles.router = {
    enablePppoe = true;
    pppoeOptionsFile = config.sops.templates."router-pppoe-options".path;
  };
}
