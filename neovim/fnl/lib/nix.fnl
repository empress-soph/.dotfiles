(local utils (require :lib.utils))

(fn normalise-pkg-name [name]
	(name:gsub "%." "-"))

(fn eval [expr]
	(let [process (vim.system ["nix" "eval" "--inputs-from" (.. (or vim.env.HOME "~") "/.dotfiles") "--raw" expr])
	      result (process:wait)]
		(if (= result.code 0)
			(utils.string.trim result.stdout))))

(fn get-pkg-revision [name]
	(or (eval (.. "nixpkgs#" name ".src.rev")
	    (-?> (eval (.. "nixpkgs#" name ".src.rev"))
	      (: :match "^https://github%.com/.+/archive/([^/]+)%.zip$")))))

(fn get-pkg-hash [name]
	(eval (.. "nixpkgs#" name ".src.outputHash")))

(fn get-pkg-version [name]
	(eval (.. "nixpkgs#" name ".version")))

(fn get-nixpkgs-revision []
	(string.match (get-pkg-version "lib") "^%d+%.%d+%.%d+%.(.+)$"))

; https://github.com/peterldowns/nix-search-cli
; nix profile install github:vic/nix-versions
(fn get-available-pkg-versions [pkg-name constraint]
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
 : get-nixpkgs-revision
 : get-pkg-hash
 : get-pkg-version
 : get-available-pkg-versions
 : nurl}
