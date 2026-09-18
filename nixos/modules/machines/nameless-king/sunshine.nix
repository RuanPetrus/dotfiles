{ pkgs, ... }:
{
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
      settings = {
        capture = "kwin";
        csrf_allowed_origins = "https://192.168.15.4:47990";
        encoder = "nvenc";
      };
    };

  };

  systemd.tmpfiles.rules = [ "z /dev/uhid 0660 root uinput - -" ];
  users.users.ruan.extraGroups = [ "uinput" ];
}
