(local snacks (require "snacks"))

(local history {})

; make mysql (kinda) osc133 compliant - WIP
; mysql --skip-binary-as-hex --prompt="$(printf '\001\033]133;A;\007\002%s:%s>\001\033]133;B;\007\002 ' "$(hostname)" '\d')" --pager="sh -c \"printf '\001\033]133;C;%s\007\002' \\\"$(tail -n1 \\\\"\\\\$HOME/.mysql_history\\\\" 2>/dev/null | perl -pe 'exit if (/^$/); print "cmdline_url=";' -pe 's/\\\040/ /g;' -pe 's/\\\134/\\\/g;' -pe 's/([^A-Za-z0-9\n])/sprintf("%%%02X", ord($1))/seg;')\\\"; while read -r line; do printf '%s\n' \\\"\\\$line\\\"; done; printf '\001\033]133;D;\007\002'\""

(fn get-lines [buf start end start-offset end-offset]
	(let [start-line (+ (. start 1) start-offset)
	      end-line   (if end (+ (. end   1) end-offset) -1)
	      lines      (vim.api.nvim_buf_get_lines buf start-line end-line true)
	      len        (length lines)
	      start-col  (?. start 2)
	      end-col    (?. end 2)]

		(if (and start-col (not (= start-col 0)))
			(let [first-line (. lines 1)]
				(tset lines 1 (first-line:sub start-col))))

		(if (and end-col (not (= end-col 0)))
			(let [last-line (. lines len)]
				(tset lines len (last-line:sub 1 (if (and (= len 1)
				                                      start-col
				                                      (not (= start-col 0)))
				                                   (- (length last-line) start-col -1)
				                                   end-col)))))
		lines))

(tset snacks.picker :terminal_cmd_history (fn []
	(snacks.picker.pick nil
		{:title "Terminal history"
			:live true
			:supports_live true
			:format "text"

			:preview (fn [ctx]
				(let [lines (get-lines ctx.item.output.buf ctx.item.output.start ctx.item.output.end -1 0)]
					(when (not (?. ctx.item.output :end))
						(table.insert lines 1 "")
						(table.insert lines 1 "--")
						(table.insert lines 1 "processing..."))
					(ctx.preview:set_lines lines)))

			:finder (fn [opts ctx]
				(fn [cb]
					(var i 0)
					(var done? false)
					(var histories (icollect [_ buf-history (ipairs history)] buf-history))
					(while (not done?)
						(set histories (icollect [_ buf-history (ipairs histories)]
							(if (>= (length buf-history) (+ i 1))
								(let [cmd-entry (?. buf-history (- (length buf-history) i))
								      cmd (table.concat (icollect [_ line (ipairs cmd-entry.cmd)]
								                          (line:match "^%s*(.-)%s*$")) " ")]
									; TODO make this a fuzzy match
									(if (cmd:find ctx.filter.search)
										(cb {:text cmd :output {:buf   cmd-entry.buf
										                        :start cmd-entry.output-start
										                        :end   cmd-entry.output-end}}))
									buf-history)
								nil)))

						(if (= (length histories) 0)
							(set done? true))

						(set i (+ i 1)))))})))

(vim.keymap.set "" "<Leader>ss"
	snacks.picker.terminal_cmd_history
	{:desc "Terminal (Shell) Buffer History"
	 :silent true})

{:history history :buf-get-lines get-lines}
