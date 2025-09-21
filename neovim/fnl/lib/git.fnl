(local utils (require :lib.utils))

(fn get-repo-dir-from-path [path]
	(let [dirpath (if (= (vim.fn.isdirectory path) 0) (vim.fs.dirname path)
	                                                  path)
		  process (vim.system ["git" "-C" dirpath "rev-parse" "--show-toplevel"])
		  result (process:wait)]
		(if (= result.code 0)
			(utils.string.trim result.stdout))))

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

(fn get-head-ref [path]
	(let [process (vim.system ["git" "-C" path "rev-parse" "--abbrev-ref" "HEAD"])
	      result (process:wait)]
		(if (= result.code 0)
			(let [ref (utils.string.trim result.stdout)]
				(if (not (= ref "HEAD"))
					ref)))))

(fn get-checked-out-tag [path]
	(let [process (vim.system ["git" "-C" path "name-rev" "--tags" "--name-only" "HEAD"])
	      result (process:wait)]
		(if (= result.code 0)
			(let [tag (utils.string.trim result.stdout)]
				(if (not (= tag "undefined"))
					tag)))))

(fn get-checked-out-commit [path]
	(let [process (vim.system ["git" "-C" path "rev-parse" "HEAD"])
	      result (process:wait)]
		(if (= result.code 0)
			(utils.string.trim result.stdout))))

(local date-formats [:relative :local :default :iso :iso-strict :rfc :short :raw])
(fn get-revision-date [path revision format]
	(let [date-arg (if (not format) "--date=default"
	                      (utils.list.contains? date-formats format) (.. "--date=" format)
	                      (.. "--date=format:" format))
		  process (vim.system ["git" "-C" path "log" "--format=%cd" date-arg "-n1" (or revision "HEAD")])
	      result (process:wait)]

		(when (= result.code 0)
			(utils.string.trim result.stdout))))

{: get-repo-dir-from-path
 : get-repo-dir-from-path-recursive
 : get-head-ref
 : get-checked-out-tag
 : get-checked-out-commit
 : get-revision-date}
