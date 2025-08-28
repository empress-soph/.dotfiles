{
	description = "~";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		mac-app-util.url = "github:hraban/mac-app-util";
	};

	outputs = { nixpkgs, home-manager, mac-app-util, ... }:
		let
		  lib = nixpkgs.lib;
		  system = "aarch64-darwin";
		  pkgs = import nixpkgs { inherit system; };
		in {
			homeConfigurations.dotfiles = home-manager.lib.homeManagerConfiguration {
				inherit lib pkgs;
				modules = [
					mac-app-util.homeManagerModules.default
					./home.nix
				];
			};
		};
}
