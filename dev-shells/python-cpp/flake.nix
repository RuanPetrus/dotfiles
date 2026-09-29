{
  description = "Python and C++ development shell";

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

        shellHook = ''
          if [ ! -d .venv ]; then
            python -m venv .venv
          fi
          source .venv/bin/activate
        '';
      };
    };
}
