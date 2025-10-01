(local utils (require :lib.utils))
(local nix (require :lib.nix))
(local git (require :lib.git))

(local lockfile-path (.. (vim.fn.stdpath :config) "/nix-pkgs.lock"))

(local nurl-url-map
	{"github.com"              "github:"
	 "git.sr.ht"               "sourcehut:"
	 "gitlab.com"              "gitlab:"
	 "gitea.com"               "gitea:"
	 "bitbucket.org"           "bitbucket:"
	 "gerrit.googlesource.com" "gitiles:"})

(fn get-nurl-src [url]
	(-> url
		(: :gsub "%.git$" "")
		(: :gsub "^https?://(.-)/~?" nurl-url-map)
		(: :gsub "^(.-)/~?" nurl-url-map)))

(fn generate-plugin-lockdata [plugin lockdata]
	(let [pkg-name (nix.normalise-pkg-name plugin.name)
	      full-pkg-name (.. "vimPlugins." pkg-name)]

		(set lockdata.commit plugin.commit)
		; (set pkg.head (git.get-head-ref plugin.dir))
		; (set pkg.tag (git.get-checked-out-tag plugin.dir))

		(if (= (nix.get-pkg-revision full-pkg-name) plugin.commit)
			(set lockdata.src (.. "nixpkgs#" full-pkg-name)))

		(when (and (not lockdata.src) plugin.url)
			(set lockdata.src (get-nurl-src plugin.url))
			(set lockdata.hash (-?> (nix.nurl plugin.url plugin.commit)
			                     (?. :hash))))

		lockdata))

(fn read-lockfile [path]
	; with-open breaks if the file doesn't exist, so do this bs to solve that
	(or (-?> (io.open path :r)
	      (#(with-open [lockfile $1] (lockfile:read :*a)))
	      (#(case (pcall vim.json.decode $1) (true json) json)))
	    []))

(fn write-lockfile [path locks]
	(with-open [lockfile (io.open path :w)]
		(lockfile:write 
			(vim.json.encode locks
				{:indent "\t" :sort_keys true}))))

(fn update-plugins-locks [plugins locks]
	(each [_ plugin (ipairs plugins)]
		(local lockdata (or (?. locks plugin.name) {}))

		(when (and plugin.url plugin.dir (not plugin.commit))
			(set plugin.commit (git.get-checked-out-commit plugin.dir)))

		(when (and plugin.url plugin.commit (not (= plugin.commit lockdata.commit)))
			(tset locks plugin.name (generate-plugin-lockdata plugin lockdata))))
	locks)

(fn update-lockfile [path]
	(local lazy (require :lazy))
	(local plugins (lazy.plugins))

	(local locks (-> (read-lockfile path)
		(update-plugins-locks plugins)))

	(write-lockfile path locks))

{: lockfile-path
 : read-lockfile
 : update-lockfile}
