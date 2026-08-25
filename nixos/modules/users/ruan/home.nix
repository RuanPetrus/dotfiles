{ pkgs, ... }:
{
  home.stateVersion = "25.11";

  home.packages = [ pkgs.ncmpcpp ];

  xdg.configFile."ncmpcpp/config".text = ''
    mpd_host = "192.168.15.3"
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
