{ lib, pkgs, utils, ... }:

{
	enable = true;

	plugins = (utils.importConfig ./plugins.nix);

	shellInit = utils.concatFiles [
		./config.fish
		./prompt.fish
	];

	interactiveShellInit = (builtins.readFile ./config.interactive.fish);

	shellAbbrs = import ./abbrs.nix;

	shellAliases = import ./aliases.nix;

	functions = import ./functions;
}
