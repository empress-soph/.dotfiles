{ lib, pkgs, utils, ... }:

{
	enable = true;

	plugins = import ./plugins.nix { inherit pkgs utils; };

	shellInit = utils.concatFiles [
		./config.fish
		./prompt.fish
	];

	interactiveShellInit = (builtins.readFile ./config.interactive.fish);

	shellAbbrs = import ./abbrs.nix;

	shellAliases = import ./aliases.nix;

	functions = import ./functions;
}
