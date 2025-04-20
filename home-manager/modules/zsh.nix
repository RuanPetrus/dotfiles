{config, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      r = "ranger";
      v = "nvim";

      build-nixos = "sudo nixos-rebuild switch --flake ~/dotfiles";
      build-home-manager = "home-manager switch --flake ~/dotfiles";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    # TODO: zsh prompt depends on git
    initExtra = builtins.readFile ../../zsh/prompt;
  };
}
