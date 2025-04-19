# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, stateVersion, hostname, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./packages.nix
      ./modules/bootloader.nix
      ./modules/networking.nix
      ./modules/nvidia.nix
      ./modules/services.nix
      ./modules/sound.nix
      ./modules/user.nix
      ./modules/x11.nix
      ./modules/gnome.nix
      ./modules/home-manager.nix
      ./modules/kernel.nix
    ];
  networking.hostName = hostname;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  console.keyMap = "br-abnt2";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = stateVersion; # Did you read the comment?
}
