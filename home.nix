{ lib, pkgs, ... }:
let
	utils = import ./utils.nix { inherit lib pkgs; };
	user = import ./user.nix;
in 
{
	home = {
		packages = with pkgs; [
			fish
			iterm2
		];

		username = user.name;
		homeDirectory = user.home;

		stateVersion = "23.11";
	};

	programs.home-manager.enable = true;
	programs.direnv.enable = true;
	programs.fish = import ./fish/default.nix { inherit lib pkgs utils; };
}
