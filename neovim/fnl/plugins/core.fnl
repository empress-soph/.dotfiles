(import-macros {: tx} :config.macros)

(fn list-merge [...]
	(let [merged-list []]
		(for [i 1 (select :# ...)]
			(let [list (select i ...)]
					(each [_ item (ipairs list)]
						(table.insert merged-list item))))))

; (local {: autoload} (require :nfnl.module))
; (local utils (autoload :config.utils))

[(tx "LazyVim/LazyVim" {})

 (tx "folke/snacks.nvim"
	{:opts
		{:indent
			{:enabled false}

		 :picker
		 	{:sources {:files {:hidden true :ignored false}}
			 :hidden true
			 :ignored true}
			; {:win {:input {:keys {"<CR>" (tx :tab {:mode [:n :i]})}}}}

		 :dim
		 	{:enabled false}}
	:init (fn []
		(let [snacks (require :snacks)]
			(tset snacks.picker :git_pickaxe (fn []
				(snacks.picker.pick nil
					{:title "Git History"
					 :live true
					 :supports_live true
					 ; :format "text"
					 :sep "\n\n"
					 :format "git_log"
					 :preview "git_show"
					 :finder (fn [opts ctx]
						(if (= "" ctx.filter.search) {}

							(let [log-args ["log"
							                "--pretty=format:%h %s (%ch)"
							                "--abbrev-commit"
							                "--decorate"
							                "--date=short"
							                "--color=never"
							                "--no-show-signature"
							                "--name-only"
							                "-G"
							                ctx.filter.search]]
							((. (require :snacks.picker.source.proc) :proc)
									[opts {:cmd "git"
										   :args log-args
										   :transform (fn [item]
											; (print (vim.inspect item.))
											(let [(commit msg date files) (item.text:match "^(%S+) (.*) %((.*)%)\n(.*)$")]
												(set item.commit commit)
												(set item.msg msg)
												(set item.date date)
												(set item.cwd nil)
												(set item.file nil)
												(set item.files (icollect [file (files:gmatch "[^\r\n]+")] file))))}] ctx))))})))

			(vim.keymap.set "" "<Leader>gp" snacks.picker.git_pickaxe {:silent true :desc "Git Pickaxe (Search Git History)"})))})

 (tx "saghen/blink.cmp"
	 {:opts
		{:signature {:enabled true}
		 :keymap {:preset "enter"
		          "<Tab>"   [:select_next :fallback]
		          "<S-Tab>" [:select_prev :fallback]}}})

 (tx "MagicDuck/grug-far.nvim" {:enabled false})
 (tx "folke/flash.nvim" {:enabled false})]

 ;(tx "akinsho/bufferline.nvim" {:enabled true})]
