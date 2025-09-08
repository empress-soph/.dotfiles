vim.g.maplocalleader = ";"

if vim.g.init_debug_instance then
	require"osv".launch({port=8086, blocking=true})
end

local lazyOpts = {
	spec = {
		-- add LazyVim and import its plugins
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- The following configs are needed for fixing lazyvim on nix
		-- force enable telescope-fzf-native.nvim
		-- { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
		-- disable mason.nvim, use programs.neovim.extraPackages
		-- { "williamboman/mason-lspconfig.nvim", enabled = false },
		-- { "williamboman/mason.nvim", enabled = false },
		-- import/override with your plugins
		{ import = "plugins" },
		-- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
		{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
	},
	defaults = {
		-- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
		-- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
		lazy = false,
		-- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
		-- have outdated releases, which may break your Neovim install.
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},
	install = {},
	checker = {
		enabled = true, -- check for plugin updates periodically
		notify = false, -- notify on update
	}, -- automatically check for plugin updates
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
}

if lazyPath then
	lazyOpts['dev'] = {
		-- reuse files from pkgs.vimPlugins.*
		path = lazyPath,
		patterns = { "" },
		-- fallback to download
		fallback = true,
	}
end

require("lazy").setup(lazyOpts)
