{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  nixosSource = ../..;
  opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
  stateDir = "/var/lib/opencode";
  sshConfig = pkgs.writeText "opencode-ssh-config" ''
    Host abiss-watcher
      HostName 100.119.1.49
      User ruan

    Host night-crawler
      HostName 100.90.89.121
      User ruan

    Host nameless-king
      HostName 100.67.121.93
      User ruan

    Host *
      BatchMode yes
      IdentitiesOnly yes
      IdentityFile ${stateDir}/.ssh/id_ed25519
      StrictHostKeyChecking yes
      UserKnownHostsFile ${stateDir}/.ssh/known_hosts
  '';
  knownHosts = pkgs.writeText "opencode-known-hosts" ''
    100.119.1.49 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv25bEkRr38yIbwfYU2KtFJ2P+K2CDcv+DyBlDLrkKE
    100.90.89.121 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeCRw+jeO/cR12DDsTsOttBAQL//AS7bd6AAFb0TOkj
    100.67.121.93 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAdgblEZnMhtkqOXSBLFHH6v30bsbgW3WxT8v4zPFWw
  '';
  startScript = pkgs.writeShellScript "opencode-start" ''
    cd ${stateDir}/workspace/dotfiles
    exec ${lib.getExe opencode} web --hostname 192.168.15.3 --port 4096
  '';
  deployAbiss = pkgs.writeShellScriptBin "opencode-deploy-abiss" ''
    set -eu

    exec ${pkgs.systemd}/bin/systemd-run \
      --unit=opencode-deploy-abiss \
      --collect \
      --no-block \
      --property=WorkingDirectory=${stateDir}/workspace/dotfiles/nixos \
      ${lib.getExe pkgs.nixos-rebuild} switch \
      --flake path:${stateDir}/workspace/dotfiles/nixos#abiss-watcher
  '';
in
{
  environment.systemPackages = [ deployAbiss ];

  users = {
    groups.opencode = { };
    users.opencode = {
      isSystemUser = true;
      group = "opencode";
      home = stateDir;
      shell = pkgs.bashInteractive;
    };
  };

  environment.etc = {
    "opencode/opencode.json".source = ./opencode/opencode.json;
    "opencode/agent/machine-manager.md".source = ./opencode/agent/machine-manager.md;
  };

  sops = {
    secrets = {
      opencode-ssh-private-key = {
        owner = "opencode";
        restartUnits = [ "opencode.service" ];
      };
      opencode-server-password.restartUnits = [ "opencode.service" ];
    };
    templates."opencode.env" = {
      owner = "opencode";
      content = ''
        OPENCODE_SERVER_PASSWORD=${config.sops.placeholder.opencode-server-password}
      '';
      restartUnits = [ "opencode.service" ];
    };
  };

  networking.firewall.interfaces.enp4s0.allowedTCPPorts = [ 4096 ];

  systemd.services.opencode = {
    description = "OpenCode machine management web interface";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];

    path = [
      pkgs.git
      pkgs.nix
      pkgs.nixos-rebuild
      pkgs.openssh
    ];

    environment = {
      HOME = stateDir;
      OPENCODE_CONFIG = "${stateDir}/.config/opencode/opencode.json";
      OPENCODE_CONFIG_DIR = "${stateDir}/.config/opencode";
      OPENCODE_SERVER_USERNAME = "ruan";
      XDG_CACHE_HOME = "${stateDir}/.cache";
      XDG_CONFIG_HOME = "${stateDir}/.config";
      XDG_DATA_HOME = "${stateDir}/.local/share";
      BROWSER = ":";
    };

    preStart = ''
      install -d -m 0700 ${stateDir}/.ssh ${stateDir}/.local/share/opencode
      install -d -m 0750 ${stateDir}/.config/opencode/agent
      install -d -m 0750 ${stateDir}/workspace
      install -m 0600 ${config.sops.secrets.opencode-ssh-private-key.path} ${stateDir}/.ssh/id_ed25519
      install -m 0600 ${sshConfig} ${stateDir}/.ssh/config
      install -m 0600 ${knownHosts} ${stateDir}/.ssh/known_hosts
      install -m 0640 /etc/opencode/opencode.json ${stateDir}/.config/opencode/opencode.json
      install -m 0640 /etc/opencode/agent/machine-manager.md ${stateDir}/.config/opencode/agent/machine-manager.md

      if [[ ! -d ${stateDir}/workspace/dotfiles/.git ]]; then
        rm -rf ${stateDir}/workspace/dotfiles
        git clone https://github.com/RuanPetrus/dotfiles.git ${stateDir}/workspace/dotfiles
        rm -rf ${stateDir}/workspace/dotfiles/nixos
        cp -a ${nixosSource} ${stateDir}/workspace/dotfiles/nixos
      fi
    '';

    serviceConfig = {
      User = "opencode";
      Group = "opencode";
      StateDirectory = "opencode";
      WorkingDirectory = stateDir;
      EnvironmentFile = config.sops.templates."opencode.env".path;
      ExecStart = startScript;
      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ stateDir ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };
}
