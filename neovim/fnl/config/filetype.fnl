(import-macros {: tx} :config.macros)

(vim.filetype.add
	{:pattern {".+" ; use this pattern rather than ".*" as other plugins use that and override it
		[(fn [path bufnr]
			(let [content (vim.api.nvim_buf_get_lines bufnr 0 1 false)
			      first-line (. content 1)]
				(if (: (vim.regex "#!/[^ ]* \\?\\(npx \\)\\?zx") :match_str first-line)
					"typescript")))
		 {:priority (- math.huge)}]}})

; (vim.treesitter.language.register "zx" "typescript")

