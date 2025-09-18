# Careful about copy/pasting, Makefiles want tabs!
# But you're not copy/pasting, are you?
.PHONY: update
update:
	home-manager switch --flake .#dotfiles

clean:
	make -C neovim clean

system-clean:
	home-manager expire-generations -d
	nix-store --gc
	nix store optimise
	nix profile wipe-history
	home-manager remove-generations old
	nix-collect-garbage -d
