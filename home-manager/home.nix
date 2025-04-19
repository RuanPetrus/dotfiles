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

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    ${builtins.getEnv "XDG_BIN_HOME"} = {
      source = ../bin;
      recursive = true;
    };
  };
  xdg.configFile = {
    nvim = {
      source = ../nvim;
      recursive = true;
    };
  };
}
