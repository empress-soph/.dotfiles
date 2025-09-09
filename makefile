# Careful about copy/pasting, Makefiles want tabs!
# But you're not copy/pasting, are you?
.PHONY: switch

switch:
	home-manager switch --flake .#dotfiles

update:
	nix flake update

clean:
	make -C neovim clean
