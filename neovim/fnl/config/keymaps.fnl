;; Keymaps are automatically loaded on the VeryLazy event
;; Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
;; Add any additional keymaps here

(vim.keymap.set "n" "k" "gk")
(vim.keymap.set "n" "j" "gj")
; (vim.keymap.set "n" "0" "g0")
; (vim.keymap.set "n" "$" "g$")
; (vim.keymap.set "n" "^" "g^")
(vim.keymap.set "i" "<Up>" "<C-o>gk" {:noremap true :silent true :buffer 0})
(vim.keymap.set "i" "<Down>" "<C-o>gj" {:noremap true :silent true :buffer 0})

; (vim.keymap.set "n" "<C-n>" ":tabnext<CR>" {:silent true})
; (vim.keymap.set "n" "<C-S-n>" ":tabprevious<CR>" {:silent true})
; (vim.keymap.set "n" "<D-A-Right>" ":tabnext<CR>" {:silent true})
; (vim.keymap.set "n" "<D-A-Left>" ":tabprevious<CR>" {:silent true})
; (vim.keymap.set "n" "<D-w>" ":q!<CR>" {:silent true})
(vim.keymap.set "n" "<C-n>" ":bnext<CR>" {:silent true})
(vim.keymap.set "n" "<C-S-n>" ":bprevious<CR>" {:silent true})
(vim.keymap.set "n" "<D-A-Right>" ":bnext<CR>" {:silent true})
(vim.keymap.set "n" "<D-A-Left>" ":bprevious<CR>" {:silent true})

(vim.keymap.set "" "<D-A-Left>" ":bprevious<CR>" {:silent true})

; (vim.keymap.set "i" "<Tab>" "pumvisible() and \"<C-n>\" or \"<Tab>\"" {:expr true :silent true})

(vim.keymap.set "n" "<f10>" ":echo \"hi<\" . synIDattr(synID(line(\".\"),col(\".\"),1),\"name\") . '> trans<' . synIDattr(synID(line(\".\"),col(\".\"),0),\"name\") . \"> lo<\" . synIDattr(synIDtrans(synID(line(\".\"),col(\".\"),1)),\"name\") . \">\"<cr>")
(vim.keymap.set :ca "q" (fn []
	(if (> (length (collect [k v (ipairs (vim.api.nvim_tabpage_list_wins 0))]
			(if (= (. (vim.api.nvim_win_get_config v) :relative) "")
				v))) 1)
		"bd"
		"q")) {:expr true})
