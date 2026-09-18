{
  config,
  pkgs,
  ...
}:
let
  host = config.dotfiles.host;
in
{
  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      firefox
      mpv
    ];
  };

  hardware.graphics.enable = true;
  networking.networkmanager.enable = true;
  programs.dconf.enable = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = host.primaryUser;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  users.users.${host.primaryUser}.extraGroups = [
    "networkmanager"
    "video"
  ];
}
