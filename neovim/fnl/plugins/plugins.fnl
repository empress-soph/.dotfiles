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
				(print "setting lschr" (vim.api.nvim_get_option_value "shiftwidth" {}))
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
		(vim.api.nvim_create_user_command :BaleiaLogs vim.g.conjure_baleia.logger.show {:bang true}))})

 (tx "Olical/conjure"
	 {:event :LazyFile
	  :ft [:fennel]
	  :config (fn []
		(let [conjure-main (require :conjure.main)
		      conjure-mapping (require :conjure.mapping)]
		  (conjure-main.main)
		  (conjure-mapping.on-filetype)))

	  :init (fn []
		(let [conjure-log (require :conjure.log)
		      conjure-log-append conjure-log.append]

			(set conjure-log.append
				(fn [lines] (conjure-log-append (icollect [_ line (ipairs lines)]
					(-> line
						(string.gsub "_G.vim.g.conjure#log#fennel#print" "print")
						(string.gsub "%(print %((macrodebug %(.+%)) true%)%)" "(%1)"))))))

			(set vim.g.conjure#log#fennel#print
				(fn [...]
					(let [conjure-log (require :conjure.log)
						  fennel-view (require :fennel.view)
						  prettified-items []]
						(for [i 1 (select :# ...)]
							(let [item (select i ...)
								  prettified-item (fennel-view item)]
								(table.insert prettified-items prettified-item)))
						(conjure-log.append
							(icollect [i prettified-item (ipairs prettified-items)]
								(if (= 1 i)
									(.. ";   printed: " prettified-item)
									(.. ";            " prettified-item)))
							{:break? true}))))

			(set vim.g.conjure#eval#gsubs
				 ; {:remove-comments ["[^\r\n][%s%c]*;.-[^\r\n]" "\n"]
				  {:print-macrodebug
					["%([%s%c]*macrodebug.+%)" #($1:gsub "^%b()" #($1:gsub "^%(macrodebug[%s%c]+%((.+)%)[%s%c]*%)" "(print (macrodebug (%1) true))"))]
				  :print-to-conjure-log
					["%([%s%c]*print.+%)" #($1:gsub "^%b()" #($1:gsub "^%(print[%s%c]+(.+)%)" "(_G.vim.g.conjure#log#fennel#print %1)"))]})

			(let [lazyvim-util (require :lazyvim.util)
			      colorize (lazyvim-util.has :baleia.nvim)]
				(if colorize
					(set vim.g.conjure#log#strip_ansi_escape_sequences_line_limit 0)
					(set vim.g.conjure#log#strip_ansi_escape_sequences_line_limit 1))
				(vim.api.nvim_create_autocmd [:BufWinEnter] 
					{:pattern :conjure-log-*
					 :callback (fn []
						(let [buffer (vim.api.nvim_get_current_buf)]
						  (when (and colorize vim.g.conjure_baleia)
							(vim.g.conjure_baleia.automatically buffer))
						  (vim.keymap.set [:n :v] "[c"
							"<CMD>call search('^; -\\+$', 'bw')<CR>"
							{:silent true :buffer true :desc "Jumps to the begining of previous evaluation output."})
						  (vim.keymap.set [:n :v] "]c"
							"<CMD>call search('^; -\\+$', 'w')<CR>"
							{:silent true :buffer true :desc "Jumps to the begining of next evaluation output."})
						  (set vim.g.conjure#mapping#doc_word :K)
						  (set vim.g.conjure#mapping#def_word :gd)))}))

		(vim.api.nvim_create_autocmd "User" 
			{:pattern "ConjureEval"
			 :callback (fn []
				(when (string.match (vim.fn.expand "%:t") "^conjure-log")
					(vim.cmd "normal G")))})))})

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

