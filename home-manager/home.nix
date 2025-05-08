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
    ./modules/rofi.nix
    # ./modules/awesome.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };

  xsession = {
    enable = true;
    initExtra = ''
      xset r rate 210 40
      bar.sh& 2> /dev/null
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    ".local/bin" = {
      source = ../bin;
      recursive = true;
    };
  };
  xdg.configFile = {
    nvim = {
      source = ../nvim;
      recursive = true;
    };
    nixpkgs = {
      source = ../nixpkgs;
      recursive = true;
    };
  };
}
