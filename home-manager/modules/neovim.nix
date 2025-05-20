{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      alejandra
      cargo
      rustc
      xclip
      lua-language-server
      pyright
      nixd
      gcc
      gnumake
      obsidian # Note taking
    ];
  };

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  # xdg.configFile."nvim/parser".source = let
  #   parsers = pkgs.symlinkJoin {
  #     name = "treesitter-parsers";
  #     paths =
  #       (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
  #         with plugins; [
  #           c
  #           lua
  #           luadoc
  #           vim
  #           vimdoc
  #           query
  #         ]))
  #       .dependencies;
  #   };
  # in "${parsers}/parser";
}
