{
	description = "~";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, ... }:
		let
		  lib = nixpkgs.lib;
		  system = "aarch64-darwin";
		  pkgs = import nixpkgs { inherit system; };
		in {
			homeConfigurations = {
				dotfiles = home-manager.lib.homeManagerConfiguration {
					inherit lib pkgs;
					modules = [ ./home.nix ];
				};
			};
		};
}
