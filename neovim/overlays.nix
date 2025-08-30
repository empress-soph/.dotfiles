(final': prev': {
	vimPlugins = prev'.vimPlugins.extend (final: prev: {
		lazy-nvim = prev.lazy-nvim.overrideAttrs (old: {
			patches = (old.patches or []) ++ [
				./patches/lazy-nvim--load-local-config-recursive.patch
			];
		});

		snacks-nvim = prev.snacks-nvim.overrideAttrs (old: {
			patches = (old.patches or []) ++ [
				./patches/snacks-nvim--allow-multi-char-separators-in-proc.patch
			];
		});
	});
})
