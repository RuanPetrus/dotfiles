{ homeStateVersion, user, ... }: {
  imports = [
    ./home-packages.nix
    ./modules/zsh.nix
    ./modules/git.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };
}
