{ lib, pkgs, utils, plugins, ... }:

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

	# extraPlugins = [ pkgs.vimPlugins.lazy-nvim ];
	# extraPlugins = [ builtins.trace ((lib.attrsets.mapAtrrsToList (name: _: name) plugins.lazy-nvim (builtins.abort "no")) ];
	extraPlugins = [ pkgs.vimPlugins.lazy-nvim ];

	extraConfigLuaPre = let
		# pluginsList = import ./plugins.nix { inherit pkgs; };
		# lazyPath = utils.linkFarm "lazy-plugins" plugins;
		# pluginsList = lib.attrsets.mapAttrsToList (_: plugin: plugin) plugins;
		# pluginsList = lib.attrsets.mapAttrsToList (name: plugin: (builtins.trace plugin plugin)) plugins;
		pluginsList = lib.attrsets.mapAttrsToList (name: plugin: plugin) plugins;
		# pluginsList = import ./plugins.nix { inherit pkgs; };
		lazyP = utils.linkFarm "lazy-plugins"
			pluginsList;
		lazyPath = builtins.trace "lazyP: ${lazyP}" lazyP;
	in ''
		local lazyPath = "${lazyPath}"
	'';

	extraConfigLua = builtins.readFile ./init.lua;
}
