{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.11";

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
