{
  inputs,
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    networkmanager.dns = "none";
  };

  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
    wget
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  users.users.ruan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZLaiIK3Q+dwdxPCYGAWspqzATww2fRPqGglLJoi6uX opencode-machine-manager@abiss-watcher"
  ];
}
