{
  config,
  pkgs,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles/config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.packages = [ pkgs.obsidian ];

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    gtk4.theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  xdg.configFile = {
    "foot/foot.ini".source = link "foot/foot.ini";
    "fuzzel/fuzzel.ini".source = link "fuzzel/fuzzel.ini";
    "mako/config".source = link "mako/config";
    "lf/lfrc".source = link "lf/lfrc";
    "lf/preview".source = link "lf/preview";
    "sway/config".source = link "sway/config";
    "waybar/config.jsonc".source = link "waybar/config.jsonc";
    "waybar/style.css".source = link "waybar/style.css";
  };
}
