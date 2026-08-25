{
  lanAddress,
  pkgs,
  ...
}:
{
  services.mpd = {
    enable = true;
    openFirewall = false;
    settings = {
      music_directory = "/data/media/library/music";
      bind_to_address = lanAddress;
      port = 6600;
      auto_update = true;
      replaygain = "album";

      audio_output = [
        {
          type = "httpd";
          name = "LAN MP3 stream";
          encoder = "lame";
          bind_to_address = lanAddress;
          port = 8000;
          bitrate = 192;
          format = "44100:16:2";
          always_on = true;
          tags = true;
        }
      ];
    };
  };

  users.users.mpd.extraGroups = [ "media" ];

  environment.systemPackages = [ pkgs.mpc ];

  networking.firewall.allowedTCPPorts = [
    6600
    8000
  ];
}
