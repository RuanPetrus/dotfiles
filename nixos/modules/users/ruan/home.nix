{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.11";

  home.packages = [ pkgs.ncmpcpp ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    extraPackages = with pkgs; [
      basedpyright
      clang-tools
      gcc
      ripgrep
      rust-analyzer
      tree-sitter
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      source "${config.home.homeDirectory}/dotfiles/config/zsh/init.zsh"
    '';
  };

  xdg.configFile."nvim/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/init.lua";

  xdg.configFile."ncmpcpp/config".text = ''
    mpd_host = "${osConfig.dotfiles.host.lanAddress}"
    mpd_port = "6600"

    user_interface = "alternative"
    header_visibility = "no"
    titles_visibility = "no"
    statusbar_visibility = "yes"
    progressbar_look = "=>-"

    song_list_format = "{%a - }{%t}|{%f}"
    song_status_format = "{%a - }{%t}|{%f}"
  '';

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "RuanPetrus";
        email = "xastroboyx11@gmail.com";
      };
      safe.directory = [ "/srv/palworld-server" ];
    };
  };
}
