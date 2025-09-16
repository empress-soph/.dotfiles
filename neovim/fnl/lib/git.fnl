(fn get-repo-dir-from-path [path]
	(let [dirpath (if (= (vim.fn.isdirectory path) 0)
			(vim.fs.dirname path)
			path)
		  process (vim.system ["git" "-C" dirpath "rev-parse" "--show-toplevel"])
		  result (process:wait)]
		(if (= result.code 0)
			(result.stdout:match "^%s*(.-)%s*$"))))

(fn get-repo-dir-from-path-recursive [base-path]
	(let [paths []]
		(var path base-path)
		(var loop true)
		(while loop
			(set path (get-repo-dir-from-path path))
			(if path
				(do
					(table.insert paths path)
					(set path (vim.fs.dirname path)))
				(set loop false)))
		paths))

{: get-repo-dir-from-path
 : get-repo-dir-from-path-recursive}
