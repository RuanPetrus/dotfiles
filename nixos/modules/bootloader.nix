{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-a8a74866-12f6-477d-8218-b07d48175609".device = "/dev/disk/by-uuid/a8a74866-12f6-477d-8218-b07d48175609";
}
