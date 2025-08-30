;; Options are automatically loaded before lazy.nvim startup
;; Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
;; Add any additional options here

(set vim.g.base-listchars
	{:tab "→ "
	 :trail "·"
	 :eol "¬"
	 ; :multispace "·"
	 :multispace "·"
	 ; :leadmultispace "⁖···"})
	 ; :leadmultispace "···"})
	 ; :leadmultispace "Ͽ···"})
	 ; :leadmultispace "⋗···"})
	 :leadmultispace "•···"}) ; set after indent plugin loaded
	 ; :leadmultispace "◦···"})
	 ; :leadmultispace "→   "})})

;; set listchars=tab:→\ ,trail:·,eol:¬,multispace:·
(set vim.opt.listchars vim.g.base-listchars)

;; set list
(set vim.opt.list true)

(set vim.opt.showbreak "↳ ")
(set vim.opt.breakindent true)
(set vim.opt.wrap true)
(set vim.opt.linebreak true)

(set vim.opt.expandtab false)
(set vim.opt.shiftwidth 4)
(set vim.opt.tabstop 4)

(set vim.opt.number false)
(set vim.opt.relativenumber false)

(set vim.opt.guifont "Fantasque Sans Script12 Mono")

(vim.cmd (.. "source " (vim.fs.joinpath (vim.fn.stdpath :config) :syntax.vim)))

; (: vim.treesitter.query :set_query "php" "highlights" "(variable name: (identifier) @variable.name (#eq? @variable.name \"$\"))")

; apparantly options is the place to set the local leader
; even though i think keymaps would make more sense
(set vim.g.maplocalleader ";")

(set vim.g.autoformat false)

(require "config.filetype")

(set vim.g.neovide_input_macos_option_key_is_meta "only_left")
