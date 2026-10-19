{ config, ... }:
{
  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
  };

  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU power limit to the VBIOS maximum";
    wantedBy = [ "graphical.target" ];
    after = [
      "display-manager.service"
      "nvidia-persistenced.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --power-limit=198";
      RemainAfterExit = true;
    };
  };

  hardware.nvidia-container-toolkit.enable = true;
}
