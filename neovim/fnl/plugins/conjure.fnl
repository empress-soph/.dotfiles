(import-macros {: tx} :config.macros)

(fn init []
	(let [conjure-log (require :conjure.log)
		  conjure-log-append-original conjure-log.append]

		(set conjure-log.append
			(fn [lines] (conjure-log-append-original (icollect [_ line (ipairs lines)]
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
				(vim.cmd "normal G")))})))

[(tx "Olical/conjure"
	 {:event :LazyFile

	  :ft [:fennel]

	  :config (fn []
		(let [conjure-main (require :conjure.main)
			  conjure-mapping (require :conjure.mapping)]
			(conjure-main.main)
			(conjure-mapping.on-filetype)))

	  :init init})]

