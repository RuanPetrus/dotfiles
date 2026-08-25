{
  osConfig,
  pkgs,
  ...
}:
let
  lanAddress = osConfig.dotfiles.host.lanAddress;
in
{
  assertions = [
    {
      assertion = lanAddress != null;
      message = "The ruan server profile requires dotfiles.host.lanAddress";
    }
  ];

  home.packages = [ pkgs.ncmpcpp ];

  xdg.configFile."ncmpcpp/config".text = ''
    mpd_host = "${lanAddress}"
    mpd_port = "6600"

    user_interface = "alternative"
    header_visibility = "no"
    titles_visibility = "no"
    statusbar_visibility = "yes"
    progressbar_look = "=>-"

    song_list_format = "{%a - }{%t}|{%f}"
    song_status_format = "{%a - }{%t}|{%f}"
  '';

  programs.git.settings.safe.directory = [ "/srv/palworld-server" ];
}
