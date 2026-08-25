{
  config,
  pkgs,
  ...
}:
let
  host = config.dotfiles.host;
in
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      brightnessctl
      bat
      chafa
      file
      foot
      firefox
      fuzzel
      grim
      mako
      networkmanagerapplet
      playerctl
      polkit_gnome
      slurp
      stress-ng
      swayidle
      swaylock
      waybar
      wl-clipboard
      glmark2
      lm_sensors
      lf
      libarchive
      poppler-utils
    ];
  };

  services = {
    dbus.enable = true;
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
        user = "greeter";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  networking.networkmanager.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
  hardware.graphics.enable = true;
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services.swaylock = { };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  users.users.${host.primaryUser}.extraGroups = [
    "networkmanager"
    "video"
  ];
}
