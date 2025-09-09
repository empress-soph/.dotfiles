{ pkgs, ... }:

with pkgs.vimPlugins; [
	# LazyVim
	LazyVim
	baleia-nvim
	blink-cmp
	bufferline-nvim
	conform-nvim
	# flash-nvim
	friendly-snippets
	gitsigns-nvim
	lazydev-nvim
	lualine-nvim
	noice-nvim
	nui-nvim
	numb-nvim
	nvim-notify
	nvim-nio
	nvim-lint
	nvim-lspconfig
	nvim-treesitter
	nvim-treesitter-context
	nvim-treesitter-textobjects
	nvim-ts-autotag
	ts-comments-nvim
	one-small-step-for-vimkind
	persistence-nvim
	plenary-nvim
	snacks-nvim
	telescope-fzf-native-nvim
	todo-comments-nvim
	trouble-nvim
	which-key-nvim
	{ name = "mini.ai"; path = mini-nvim; }
	{ name = "mini.comment"; path = mini-nvim; }
	{ name = "mini.pairs"; path = mini-nvim; }

	conjure
	nfnl
	rainbow-delimiters-nvim
	muren-nvim
]
