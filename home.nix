{ lib, pkgs, config, ... }:

let
	user = import ./user.nix;
	utils = import ./utils { inherit lib pkgs config user; };

	importConfig = (path:
		import path {
			inherit lib pkgs config user;
			utils = utils.merge [utils { inherit importConfig; }];
		}
	);

	configure = (entries:
		(utils.merge (map (entry:
			if (builtins.typeOf entry) == "path" then
				(importConfig entry)
			else
				entry
		) entries))
	);

in (configure ([{

	imports = [
		(import ./utils/mutability.nix { inherit config lib; })
	];

	home = {
		packages = with pkgs; [
			fish
			iterm2
			fennel
		];

		username = user.name;
		homeDirectory = user.home;

		stateVersion = "23.11";
	};

	nixpkgs.overlays = [
		(import ./neovim/overlays.nix)
	];

	programs.home-manager.enable = true;
	programs.direnv.enable = true;

}] ++ [
	./fish
	./neovim
]))
