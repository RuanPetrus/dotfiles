{
  description = "Raspberry Pi Pico C/C++ development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Normal development tools
          clang-tools
          cmake
          gdb
          git
          ninja
          pkg-config

          # Raspberry Pi Pico
          pico-sdk
          picotool

          # ARM Cortex-M cross compiler
          gcc-arm-embedded

          # Useful for USB/debugging
          libusb1
          openocd
        ];

        shellHook = ''
          export PICO_SDK_PATH=${pkgs.pico-sdk}/lib/pico-sdk

          echo "Pico SDK: $PICO_SDK_PATH"
          echo "ARM GCC:  $(arm-none-eabi-gcc --version | head -n1)"
        '';
      };
    };
}
