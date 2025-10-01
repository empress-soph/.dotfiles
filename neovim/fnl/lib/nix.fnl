(local utils (require :lib.utils))

(fn normalise-pkg-name [name]
	(name:gsub "%." "-"))

(fn get-pkg-revision [name]
	(let [process (vim.system ["nix" "eval" "--inputs-from" (.. (or vim.env.HOME "~") "/.dotfiles") "--raw" (.. "nixpkgs#" name ".src.rev")])
	      result (process:wait)]
		(if (= result.code 0)
			(result.stdout:match "^%s*\"(.-)\"%s*$"))))

(fn nurl [url revision]
	(let [process (vim.system ["nurl" "--json" url revision])
	      result (process:wait)]
		(if (= result.code 0)
			(let [nurl-json (vim.json.decode (utils.string.trim result.stdout))]
				nurl-json.args))))

{: normalise-pkg-name
 : get-pkg-revision
 : nurl}
