{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixarr.url = "github:nix-media-server/nixarr";
    opencode.url = "github:anomalyco/opencode";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      mkHost =
        {
          modules,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs;
          };

          modules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
          ]
          ++ modules;
        };
    in
    {
      lib = { inherit mkHost; };

      nixosConfigurations.abiss-watcher = mkHost {
        modules = [ ./modules/machines/abiss-watcher ];
      };
    };
}
