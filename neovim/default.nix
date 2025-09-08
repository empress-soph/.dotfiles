{ lib, pkgs, utils, user, ... }:

utils.merge ([{
	programs.nixvim = import ./program.nix { inherit lib pkgs utils; };

	xdg.configFile."nvim/lua".source = pkgs.stdenv.mkDerivation rec {
		name = "${user.name}-neovim-compiled-lua"; src = ./.;

		buildInputs = [
			pkgs.lua
			pkgs.vimPlugins.nfnl
		];

		buildPhase   = ''make FENNEL_PATH="${pkgs.vimPlugins.nfnl}/script/fennel.lua"'';
		installPhase = ''mv lua "$out"'';
	};

	xdg.configFile."nvim/treesitter".source = ./treesitter;

	xdg.configFile."nvim/themes".source = ./themes;

	xdg.configFile."nvim/syntax.vim".source = ./syntax.vim;

	xdg.configFile."nvim/lazyvim.json".source = ./lazyvim.json;

	# https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
	xdg.configFile."nvim/parser".source = let
		parsers = pkgs.symlinkJoin {
			name = "treesitter-parsers";
			paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins
				(plugins: with plugins; [
					c
					lua
					fennel
				])).dependencies;
		};
	in "${parsers}/parser";

	xdg.configFile.neovim.source = utils.mkMutableSymlink ./.;
}]

++

(map
	(plugin: {
		xdg.dataFile."nvim/lazy/${plugin.name}" = {
			source = plugin.path;
			mutable = true;
			force = true;
		};
	})

	(map
		(drv:
			if lib.isDerivation drv then
				{ name = "${lib.getName drv}"; path = drv; }
			else
				drv
		)

		(import ./plugins.nix { inherit pkgs; })
	)
))
