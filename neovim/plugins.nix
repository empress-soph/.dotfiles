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
	{ name = "mini.hipatterns"; path = mini-nvim; }
	{ name = "mini.icons"; path = mini-nvim; }

	conjure
	nfnl
	rainbow-delimiters-nvim
	muren-nvim
	git-blame-nvim
	grug-far-nvim
	lush-nvim
	nvim-dap
	nvim-dap-ui
	nvim-treesitter-sexp
	indent-o-matic
	nvim-dap-virtual-text
	nvim-dap-ui
]
