(local snacks (require "snacks"))

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
				(if (= "" ctx.filter.search)
					{}
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
							       	(let [(commit msg date files) (item.text:match "^(%S+) (.*) %((.*)%)\n(.*)$")]
							       		(set item.commit commit)
							       		(set item.msg msg)
							       		(set item.date date)
							       		(set item.cwd nil)
							       		(set item.file nil)
							       		(set item.files (icollect [file (files:gmatch "[^\r\n]+")] file))))}] ctx))))})))

(vim.keymap.set "" "<Leader>gp"
	snacks.picker.git_pickaxe
	{:desc "Git Pickaxe (Search Git History)"
	 :silent true})
