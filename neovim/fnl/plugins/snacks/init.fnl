(import-macros {: tx} :config.macros)

(local utils (require :lib.utils))

(local ignorefiles {})

(fn generate-vcs-ignore-globs [dir]
	(vim.fn.system
		["fd" "--base-directory" dir
		 "-H"
		 "-L" ".gitignore"
		 "--strip-cwd-prefix"
		 "-x" "perl"
			"-pe" "s~(!)?(.*?)~\\1/{//}/**/\\2~;"
			"-pe" "s~^/\\./\\*\\*/~~;"
			"-pe" "s~({//}/)\\*\\*//~\\1~;" "{}"]))

(fn generate-ignore-globs [exclude-globs include-globs]
  (let [ignore-globs (or exclude-globs [])]
	(each [_ glob (ipairs (or include-globs []))]
	  (let [sanitised-glob (-> glob
	                         (: :gsub "/$" "")
	                         (: :gsub "/%*$" "")
	                         (: :gsub "/%*%*$" "")
	                         (: :gsub "/$" ""))
	        parts (vim.split sanitised-glob "/")]
		(var path "")
		(each [i part (ipairs parts)]
			(set path (.. path part))

			(let [include-dir-glob (.. "!" path)]
				(when (not (utils.contains? ignore-globs include-dir-glob))
					(table.insert ignore-globs include-dir-glob)))

			(when (not (= (length parts) i))
				(let [exclude-dir-contents-glob (.. path "/*")]
					(when (not (utils.contains? ignore-globs exclude-dir-contents-glob))
						(table.insert ignore-globs exclude-dir-contents-glob)))
				(set path (.. path "/"))))))

	(table.concat ignore-globs "\n")))

(fn write-tmpfile [content]
	(let [fname (os.tmpname)]
		(with-open [file (io.open fname :w)]
			(file:write content)
				fname)))

(fn get-ignorefile [cwd name generate-cb]
  (if (not (. ignorefiles cwd))
	  (tset ignorefiles cwd {}))
  (or (. ignorefiles cwd type)
	  (let [ignorefile (write-tmpfile (generate-cb))]
	  	(tset ignorefiles cwd name ignorefile)
		ignorefile)))

(fn set-ignore-args [opts]
	(when (not opts.args)
		(set opts.args []))

	(when (= opts.show_libs nil)
		(set opts.show_libs vim.g.pickers_show_libs))
	(set vim.g.pickers_show_libs opts.show_libs)

	(let [vcs-ignorefile (get-ignorefile opts.cwd :vcs (fn [] (generate-vcs-ignore-globs opts.cwd)))
			vcs-ignorefile-arg (.. "--ignore-file=" vcs-ignorefile)
			libs-ignorefile (get-ignorefile opts.cwd :libs (fn [] (generate-ignore-globs [] opts.libs)))
			libs-ignorefile-arg (.. "--ignore-file=" libs-ignorefile)]
		(set opts.args (icollect [_ arg (ipairs opts.args)]
			(if (not (or (= arg "--no-ignore-vcs")
						(= arg vcs-ignorefile-arg)
						(= arg libs-ignorefile-arg)))
				arg)))
		(if (not opts.ignore)
			(when opts.show_libs
				(table.insert opts.args "--no-ignore-vcs")
				(table.insert opts.args vcs-ignorefile-arg)
				(table.insert opts.args libs-ignorefile-arg)))))

[(tx "folke/snacks.nvim"
	{:opts
		{:indent
			{:enabled false}

		 :picker
		 	{:sources
				{:files {:toggles {:show_libs "l"}
				         :cmd "fd"
				         :finder (fn [opts ctx] (set-ignore-args opts) ((. (require "snacks.picker.source.files") :files) opts ctx))
				         :win {:input {:keys {"<a-l>" (tx "toggle_show_libs" {:mode [:n :i]})}}}}

				 :grep {:toggles {:show_libs "l"}
				         :cmd "rg"
				         :finder (fn [opts ctx] (set-ignore-args opts) ((. (require "snacks.picker.source.grep") :grep) opts ctx))
				         :win {:input {:keys {"<a-l>" (tx "toggle_show_libs" {:mode [:n :i]})}}}}}

			 ; https://github.com/folke/snacks.nvim/issues/1217#issuecomment-2661465574
			 :actions {:calculate_file_truncate_width (fn [self] (set self.opts.formatters.file.truncate (- (. (self.list.win:size) :width) 6)))}
			 :win {:list {:on_buf (fn [self] (self:execute :calculate_file_truncate_width))}
			       :preview {:on_buf (fn [self] (self:execute :calculate_file_truncate_width))
			                 :on_close (fn [self] (self:execute :calculate_file_truncate_width))
			                 :keys {"<Esc>" (tx "focus_input" {:mode [:n]})}}
			       :input {:keys {"/" (tx "focus_preview" {:mode [:n]})}}}

			 :layout {:preset (fn [] (if (>= (/ vim.o.lines vim.o.columns) 0.4) "vertical" "default"))}}

		 :dim
		 	{:enabled false}}

	:init (fn []
		(let [snacks (require :snacks)
			  layouts (require :snacks.picker.config.layouts)]
			(tset layouts :vertical :layout :width 0.85)
			(tset layouts :vertical :layout :height 0.9)
			(tset layouts :vertical :layout 3 :height 0.8)
			(tset layouts :vertical :layout :backdrop nil)
			(tset layouts :default :layout :width 0.85)
			(tset layouts :default :layout 2 :width 0.66)

			(require "plugins.snacks.pickers.terminal-history")
			(require "plugins.snacks.pickers.git-pickaxe")))})]
