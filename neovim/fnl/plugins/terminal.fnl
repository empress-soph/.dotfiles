(import-macros {: tx} :config.macros)

[(tx "xb-bx/editable-term.nvim"
	{:config true
	 :init (fn []
		(let [editableterm (require :editable-term)]
			(editableterm.setup
				; misspelled in the plugin...
				{:promts {"⋊> " {}
				          "mysql>" {}}})

			(fn get-prompt-cursor [buf]
				(?. editableterm.buffers buf :promt_cursor))

			(fn cursor-on-prompt? [buf]
				(let [prompt-line (?. (get-prompt-cursor buf) 1)
					  cursor-line (?. (vim.api.nvim_win_get_cursor 0) 1)]
					(if (and prompt-line (<= cursor-line prompt-line))
						true
						nil)))

			(fn prompt-is-empty? [buf]
				(let [[prompt-line prompt-col] (?. editableterm.buffers buf :promt_cursor)]
					(if (and prompt-line prompt-col
						     (= (string.sub (. (vim.api.nvim_buf_get_lines buf (- prompt-line 1) prompt-line true) 1) (+ prompt-col 1)) ""))
						true
						nil)))

			(vim.api.nvim_create_autocmd :TermOpen
				{:pattern "*" :callback (fn [args]
					(let [buf           args.buf
					      cmd-stack     [{:buf buf}]
					      history       (. (require "plugins.snacks.pickers.terminal-history") :history)
					      buf-get-lines (. (require "plugins.snacks.pickers.terminal-history") :buf-get-lines)
					      buf-history   []]

						(tset history buf buf-history)

						(vim.api.nvim_create_autocmd :TermRequest
							{:buffer buf :callback (fn [args]
								(print args.data.sequence (vim.inspect args.data.cursor))

								(when (= (length cmd-stack) 0)
									(table.insert cmd-stack {:buf buf}))

								(let [current (?. cmd-stack (length cmd-stack))
								      current-cmd (or (-?>> (?. current :history-position) (?. buf-history)) current)]

									(when (string.match args.data.sequence "^\027]133;A")
										(if (?. current-cmd :output-start)
											(table.insert cmd-stack {:buf buf :prompt-start args.data.cursor})
											(set current-cmd.prompt-start args.data.cursor)))

									(when (string.match args.data.sequence "^\027]133;B")
										(if (?. current-cmd :output-start)
											(table.insert cmd-stack {:buf buf :prompt-end args.data.cursor})
											(set current-cmd.prompt-end args.data.cursor)))

									(when (string.match args.data.sequence "^\027]133;C")
										(let [cmdline-url (-?> (string.match args.data.sequence "^\027]133;C;cmdline_url=(.*)")
										                    (: :gsub "+" " ")
										                    (: :gsub "%%(%x%x)" (fn [c] (string.char (tonumber c 16)))))

										      cmd (if cmdline-url
										          [cmdline-url]
										            (buf-get-lines buf current-cmd.prompt-end args.data.cursor -1 -1))]
											(if (?. current-cmd :output-start)
												(let [new {:buf buf :cmd cmd :output-start args.data.cursor :parent-cmd (length buf-history)}]
													(table.insert buf-history new)
													(table.insert cmd-stack {:history-position (length buf-history)}))
												(do
													(set current-cmd.output-start args.data.cursor)
													(set current-cmd.cmd cmd)
													(table.insert buf-history current-cmd)
													(set current-cmd.history-position (length buf-history))))))

									(when (string.match args.data.sequence "^\027]133;D")
										(let [exit-code (string.match args.data.sequence "^\027]133;D;(.*)")]
											(if exit-code
												(set current-cmd.exit-code exit-code)))
										(if (?. current-cmd :output-start)
											(set current-cmd.output-end [(- (. args.data.cursor 1) 1) (. args.data.cursor 2) ]))
										(table.remove cmd-stack)
										(if (= (length cmd-stack) 0)
											(table.insert cmd-stack {:buf buf})))))}))

					(vim.keymap.set :t "<ESC>"
						"<C-\\><C-n>"
						{:noremap true :buffer args.buf})

					(vim.keymap.set :n "<ESC>" (fn []
						(if (cursor-on-prompt? args.buf)
							"A<ESC><C-\\><C-n>"
							"<ESC>"))
						{:noremap true :buffer args.buf :expr true})

					(vim.keymap.set :n "<CR>" "A<CR>"
						{:noremap true :buffer args.buf})

					(vim.keymap.set :n "K" (fn []
						(if (cursor-on-prompt? args.buf)
							"gk" "K"))
						{:noremap true :buffer args.buf :expr true})

					(vim.keymap.set :n "k" (fn []
						(if (cursor-on-prompt? args.buf)
							(if (prompt-is-empty? args.buf) "A<C-c><UP><C-\\><C-n>" "A<UP><C-\\><C-n>") "gk"))
						{:noremap true :buffer args.buf :expr true})

					(vim.keymap.set :n "j" (fn []
						(if (cursor-on-prompt? args.buf)
							"A<DOWN><C-\\><C-n>" "gj"))
						{:noremap true :buffer args.buf :expr true}))})))})]
