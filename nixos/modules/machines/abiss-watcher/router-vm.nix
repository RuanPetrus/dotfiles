{
  inputs,
  ...
}:
{
  imports = [ inputs.microvm.nixosModules.host ];

  networking.networkmanager.unmanaged = [
    "interface-name:enp3s0f0"
    "interface-name:enp3s0f1"
    "interface-name:enp4s0f0"
    "interface-name:enp4s0f1"
  ];

  microvm.vms.router = {
    autostart = true;
    flake = inputs.self;
    restartIfChanged = true;
  };
}
