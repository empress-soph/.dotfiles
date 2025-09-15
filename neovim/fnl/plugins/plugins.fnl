(import-macros {: tx} :config.macros)

[(tx "f-person/git-blame.nvim"
	{:opts
		{:enabled true
		 :message_template " <author> • <date> • <summary>"
		 :date_format "%r (%d %b)"
		 :message_when_not_commited "Uncommited"}})

 (tx "hiphish/rainbow-delimiters.nvim"
	{:submodules false})

 (tx "nvim-treesitter/nvim-treesitter-context"
	{:submodules false
	 :opts
		{:mode "cursor"
		 :max_lines 1}})

 (tx "Darazaki/indent-o-matic" {:opts {} :init (fn []
	(vim.api.nvim_create_autocmd [:BufReadPost] 
		{:callback (fn []
			(var new-leadmultispace "•")
			(let [buffer (vim.api.nvim_get_current_buf)]
				(for [i 1 (- (vim.api.nvim_get_option_value "shiftwidth" {}) 1)]
					(set new-leadmultispace (.. new-leadmultispace "·"))))
			(set vim.opt.listchars (vim.tbl_extend :force vim.g.base-listchars {:leadmultispace new-leadmultispace})))}))})

 (tx "m-demare/hlargs.nvim"
	{:opts {:extras {:named_parameters true}}})

 (tx "m00qek/baleia.nvim"
	 {:opts {:line_starts_at 3}
	  :config (fn [_ opts]
		(set vim.g.conjure_baleia (: (require :baleia) :setup opts))

		(vim.api.nvim_create_user_command :BaleiaColorize (fn []
			(vim.g.conjure_baleia.once (vim.api.nvim_get_current_buf)))
			{:bang true})

		(vim.api.nvim_create_user_command :BaleiaLogs
			vim.g.conjure_baleia.logger.show
			{:bang true}))})

 (tx "Olical/nfnl" {:ft "fennel"})

 ; (tx "Grazfather/sexp.nvim" {:opts {}})
 (tx "PaterJason/nvim-treesitter-sexp"
	 {:opts {}})

 ; (tx "abecodes/tabout.nvim"
 ; {:event :InsertCharPre
 ;  :opts {}
 ;  :dependencies ["saghen/pluginSblink.cmp"]})

 ; (tx "thyrum/vim-stabs" {:config (fn [])})

 (tx "AckslD/muren.nvim"
	{:config true
	 :init (fn []
		(vim.keymap.set "" "<Leader>sr" ":MurenToggle<CR>" {:silent true :desc "Search and Replace"}))})

 (tx "othree/eregex.vim" {:enabled false :otps {}})

 (tx "nacro90/numb.nvim" {:opts {}})

 (tx "Goose97/timber.nvim" {:opts {}})

 (tx "mistweaverco/kulala.nvim"
   {:opts {:global_keymaps {"Send request under cursor" (tx "<localleader>ee" (fn [] (: (require :kulala) :run)) {:mode [:n :v] :ft ["http" "rest"]})
                            "Send request undor cursor" (tx "<localleader>er" (fn [] (: (require :kulala) :run)) {:mode [:n :v] :ft ["http" "rest"]})
                            "Send all requests in buffer" (tx "<localleader>eb" (fn [] (: (require :kulala) :run_all)) {:mode [:n :v] :ft ["http" "rest"]})
                            "Send previous request" (tx "<localleader>ep" (fn [] (: (require :kulala) :replay)) {:mode [:n :v] :ft ["http" "rest"]})
                            "Send previous request" (tx "<leader>rp" (fn [] (: (require :kulala) :replay)) {:mode [:n :v]})}
           :ui {:display_mode "float"}
           :additional_curl_options ["--insecure"]}})]

