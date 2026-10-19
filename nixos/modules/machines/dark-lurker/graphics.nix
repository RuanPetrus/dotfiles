{ config, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    package:
    builtins.elem (lib.getName package) [
      "discord"
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
      "obsidian"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # The GeForce MX150 is a Pascal GPU and does not support the open module.
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    powerManagement.enable = true;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };
}
