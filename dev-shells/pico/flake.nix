{
  description = "Raspberry Pi Pico C/C++ development shell";

  inputs = {
    cpp.url = "path:../cpp";
    cpp.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { cpp, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ cpp.devShells.${system}.default ];

        packages = with pkgs; [
          pico-sdk
          picotool
          libusb1
          openocd
        ];

        shellHook = ''
          export PICO_SDK_PATH=${pkgs.pico-sdk}/lib/pico-sdk
        '';
      };
    };
}
