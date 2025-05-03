{pkgs, ...}: {
  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs {
      src = /home/ruan/dev/dwm;
    };
  };
}
