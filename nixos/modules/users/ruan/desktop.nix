{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles/config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  xdg.configFile = {
    "foot/foot.ini".source = link "foot/foot.ini";
    "fuzzel/fuzzel.ini".source = link "fuzzel/fuzzel.ini";
    "mako/config".source = link "mako/config";
    "sway/config".source = link "sway/config";
    "waybar/config.jsonc".source = link "waybar/config.jsonc";
    "waybar/style.css".source = link "waybar/style.css";
  };
}
