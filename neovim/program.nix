{ lib, pkgs, utils, ... }:

{
	enable = true;

	enableMan = false;
	withPython3 = false;
	withRuby = false;

	extraPackages = with pkgs; [
		fennel
		stylua
		ripgrep
		fd
	];

	plugins = {
		lsp = {
			enable = true;
			servers = {
				nil_ls.enable = true;
				lua_ls.enable = true;
				fennel_ls.enable = true;

				marksman.enable = true;
				bashls.enable = true;
				jsonls.enable = true;
				vtsls.enable = true;

				html.enable = true;
			};
		};
	};

	extraPlugins = [ pkgs.vimPlugins.lazy-nvim ];

	extraConfigLuaPre = let
		# plugins = import ./plugins.nix { inherit pkgs; };
		plugins = lib.attrsets.mapAttrsToList (_: plugin: plugin) (utils.importLockfilePkgs { lockfile = ./nix-pkgs.lock; nixpkgsPath = ["vimPlugins"]; });
		lazyPath = utils.linkFarm "lazy-plugins" plugins;
	in ''
		local lazyPath = "${lazyPath}"
	'';

	extraConfigLua = builtins.readFile ./init.lua;
}
