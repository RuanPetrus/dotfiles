{
  homeStateVersion,
  user,
  ...
}: {
  imports = [
    ./home-packages.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/alacritty.nix
    ./modules/neovim.nix
    ./modules/stylix.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };

  xsession = {
    enable = true;
    initExtra = "xset r rate 210 40";
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
