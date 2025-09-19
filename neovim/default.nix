{ config, lib, pkgs, utils, user, ... }:

{
	programs.nixvim = import ./program.nix { inherit lib pkgs utils; };

	xdg.configFile."nvim/lua".source = let
		nixvim = config.programs.nixvim.build.package;
		nixvim-init = config.programs.nixvim.build.initFile;
	in pkgs.stdenv.mkDerivation rec {
		name = "${user.name}-neovim-compiled-lua"; src = ./.;

		buildInputs = [
			nixvim
		];

		buildPhase   = ''
			nvim="${nixvim}/bin/nvim"

			home="$(mktemp -d)"
			mkdir -p "$home/.config/nvim"
			ln -s "${nixvim-init}" "$home/.config/nvim/init.lua"

			# trust .nfnl.fnl before running make so it's config can
			# be read/executed and the fennel can compile
			HOME="$home" "$nvim" --headless -n -i NONE ".nfnl.fnl" +trust +q

			make NVIM_PATH="$nvim" HOME="$home"

			rm -rf "$home"
		'';

		installPhase = ''mv lua "$out"'';
	};

	xdg.configFile."nvim/treesitter".source = ./treesitter;

	xdg.configFile."nvim/themes".source = ./themes;

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

	xdg.dataFile."fennel-ls/docsets/nvim.lua".source = let
		nvim-docset = pkgs.fetchFromSourcehut {
			owner = "~micampe";
			repo = "fennel-ls-nvim-docs";
			rev = "main";
			hash = "sha256-DVGw6xbSzxV9zXaQM3aDPWim3t/yIT3Hxorc4ugHDfo=";
		};
	in "${nvim-docset}/nvim.lua";
}
