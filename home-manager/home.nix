{ homeStateVersion, user, ... }: {
  imports = [
    ./home-packages.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/alacritty.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };
}
