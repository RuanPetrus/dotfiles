{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-eui.0000000000000000ace42e00356ca41d";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "ESP";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        cryptroot = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "8G";
                };
              };
            };
          };
        };
      };
    };
  };
}
