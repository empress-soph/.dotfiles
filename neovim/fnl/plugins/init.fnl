(import-macros {: tx} :config.macros)

(local config-dir (.. (or vim.env.XDG_CONFIG_HOME "~/.config") "/" (or vim.env.NVIM_APPNAME "nvim")))

[(tx "rktjmp/lush.nvim")
 (tx {:dir (.. config-dir "/themes/soft_era") :lazy true})

 (tx "LazyVim/LazyVim"
	{:opts
		{:colorscheme "soft_era"}})

 {:import "plugins.core"
  :import "plugins.snacks"}]
