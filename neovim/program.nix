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

	extraPlugins = with pkgs.vimPlugins; [ lazy-nvim ];

	extraConfigLuaPre = let
		lazy-path = utils.linkFarm "lazy-plugins"
			(lib.attrsets.mapAttrsToList (name: plugin: plugin) plugins);
	in ''
		local lazyPath = "${lazy-path}"
	'';

	extraConfigLua = builtins.readFile ./init.lua;
}
