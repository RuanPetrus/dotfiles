{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;

  microvm = {
    hypervisor = "qemu";
    vcpu = 2;
    mem = 3072;
    socket = "control.socket";
    registerWithMachined = true;

    interfaces = [
      {
        type = "user";
        id = "router-mgmt";
        mac = "02:00:00:00:00:01";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host = {
          address = "127.0.0.1";
          port = 2222;
        };
        guest.port = 22;
      }
    ];

    devices =
      map
        (path: {
          bus = "pci";
          inherit path;
        })
        [
          "0000:03:00.0"
          "0000:03:00.1"
          "0000:04:00.0"
          "0000:04:00.1"
        ];

    volumes = [
      {
        image = "router-data.img";
        mountPoint = "/var";
        size = 16384;
        fsType = "ext4";
        label = "router-data";
        autoCreate = true;
      }
    ];
  };
}
