{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    lz4
    p7zip
    unzip
  ];

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

  programs.tmux = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      source "${config.home.homeDirectory}/dotfiles/config/zsh/init.zsh"
      source "${config.home.homeDirectory}/dotfiles/config/shell/functions.sh"
    '';
  };

  xdg.configFile."nvim/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/init.lua";
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/tmux/tmux.conf";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "RuanPetrus";
        email = "xastroboyx11@gmail.com";
      };
    };
  };
}
