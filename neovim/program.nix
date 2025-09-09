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

	extraConfigLua = let
		plugins = import ./plugins.nix { inherit pkgs; };
		mkEntryFromDrv = drv:
			if lib.isDerivation drv then
				{ name = "${lib.getName drv}"; path = drv; }
			else
				drv;
		lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
	in lib.concatStringsSep "\n\n" [
		''local lazyPath = "${lazyPath}"''
		(builtins.readFile ./init.lua)
	];
}
