{
	description = "~";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		mac-app-util.url = "github:hraban/mac-app-util";
		# mac-app-util.inputs.nixpkgs.follows = "nixpkgs";

		nixvim.url = "github:nix-community/nixvim";
		nixvim.inputs.nixpkgs.follows = "nixpkgs";

		nixcasks.url = "github:jacekszymanski/nixcasks";
		nixcasks.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		nixpkgs,
		home-manager,
		mac-app-util,
		nixvim,
		nixcasks,
		...
	}: let
		user = import ./user.nix;
		lib = nixpkgs.lib;
		system = user.system;
		pkgs = import nixpkgs {
			inherit system;
			config.allowUnfree = true;
			config.packageOverrides = prev: {
				nixcasks = import nixcasks {
					inherit pkgs nixpkgs;
					osVersion = user.macOsVersion;
				};
			};
		};
	in {
		homeConfigurations.dotfiles = home-manager.lib.homeManagerConfiguration {
			inherit lib pkgs;

			modules = [
				mac-app-util.homeManagerModules.default
				nixvim.homeModules.nixvim
				./home.nix
			];
		};

		nixcasks = (nixcasks.output {
			osVersion = user.macOsVersion;
		}).packages.${system};
	};
}
