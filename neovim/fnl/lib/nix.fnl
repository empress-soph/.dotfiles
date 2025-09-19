(local utils (require :lib.utils))

(fn normalise-pkg-name [name]
	(name:gsub "%." "-"))

(fn get-pkg-revision [name]
	(let [process (vim.system ["nix" "eval" "--inputs-from" (.. (or vim.env.HOME "~") "/.dotfiles") "--raw" (.. "nixpkgs#" name ".src.rev")])
	      result (process:wait)]
		(if (= result.code 0)
			(result.stdout:match "^%s*\"(.-)\"%s*$"))))

(fn get-pkg-versions [pkg-name constraint]
	(let [query (if constraint (.. pkg-name "@" constraint) pkg-name)
	      process (vim.system ["nix-versions" query])
	      result (process:wait)]
		(if (= result.code 0)
			(let [lines (utils.string.split (utils.string.trim result.stdout) "[^\r\n]+")
			      header (. (utils.list.slice lines 1 1) 1)
			      body (utils.list.unique (utils.list.slice lines 2))
			      versions (utils.misc.parse-text-table header body)]
				(table.sort versions (fn [a b] (> a.version b.version)))
				versions))))

(fn nurl [url revision]
	(let [process (vim.system ["nurl" "--json" url revision])
	      result (process:wait)]
		(if (= result.code 0)
			(let [nurl-json (vim.json.decode (utils.string.trim result.stdout))]
				nurl-json))))

{: normalise-pkg-name
 : get-pkg-revision
 : get-pkg-versions
 : nurl}
