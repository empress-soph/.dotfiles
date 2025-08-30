{ lib, pkgs, utils, ... }:

{
	programs.fish = (utils.importConfig ./program.nix);
}
