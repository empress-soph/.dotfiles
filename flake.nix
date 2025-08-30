{
	description = "~";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		mac-app-util.url = "github:hraban/mac-app-util";

		nixvim = {
			url = "github:nix-community/nixvim";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, mac-app-util, nixvim, ... }:
		let
			lib = nixpkgs.lib;
			system = "x86_64-darwin";
			pkgs = import nixpkgs { inherit system; };
		in {
			homeConfigurations.dotfiles = home-manager.lib.homeManagerConfiguration {
				inherit lib pkgs;

				modules = [
					mac-app-util.homeManagerModules.default
					nixvim.homeModules.nixvim
					./home.nix
				];
			};
		};
}
