{
	description="System configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		home-manager = {
      			url = "github:nix-community/home-manager/release-24.11";
      			inputs.nixpkgs.follows = "nixpkgs";
    		};
	};

	outputs = {nixpkgs, home-manager, ...}@inputs : let
		system = "x86_64-linux";
    		stateVersion = "24.11";
    		homeStateVersion = "24.11";
    		user = "ruan";
		hostname = "nixos";
	in {
		nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
			system = system;
			specialArgs = {
        			inherit inputs stateVersion hostname user;
      			};
			modules = [ ./nixos/configuration.nix ];
		};
		homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
		      pkgs = nixpkgs.legacyPackages.${system};
		      extraSpecialArgs = {
			inherit inputs homeStateVersion user;
		      };

		      modules = [
			./home-manager/home.nix
		      ];
		};
	};
}
