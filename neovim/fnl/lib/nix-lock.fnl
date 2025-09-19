(local utils (require :lib.utils))
(local nix (require :lib.nix))
(local git (require :lib.git))

(local plugins-lockfile-path (.. (vim.fn.stdpath :config) "/nix-pkgs.lock"))

(local nurl-url-map
	{"github.com"              "github:"
	 "git.sr.ht"               "sourcehut:"
	 "gitlab.com"              "gitlab:"
	 "gitea.com"               "gitea:"
	 "bitbucket.org"           "bitbucket:"
	 "gerrit.googlesource.com" "gitiles:"})

(fn get-src [original-url fetcher]
	(local url (-> original-url
		(: :gsub "%.git$" "")
		(: :gsub "^https?://" "")))
	(if (= fetcher "fetchFromGithub") (url:gsub "^github.com" "")
	    (= fetcher "fetchFromSourcehut") (url:sub "^git.sr.ht" "")
	    (= fetcher "fetchFromGitea") (url:sub "^gitea.com" "")
	    (= fetcher "fetchFromGitlab") (url:sub "^gitlab.com" "")
	    (= fetcher "fetchFromBitbucket") (url:sub "^bitbucket.org" "")
	    (= fetcher "fetchFromGitiles") (url:sub "^gerrit.googlesource.com" "")
	    (= fetcher "fetchFromRepoOrCz") (url:sub "^repo.or.cz" "")
	    url))

(fn get-version-restraint [path]
	(let [process (vim.system ["git" "-C" path "log" "--format=%cd" "--date=format:%Y-%m-%d" "-n1" "HEAD"])
	      result (process:wait)]

		(when (= result.code 0)
			(local date-str (utils.string.trim result.stdout))
			(local (year month day) (date-str:match "^(.-)%-(.-)%-(.-)$"))

			(.. "^("  year "-" month "-0*" (utils.regexp.generate-number-upper-bound-regexp day)
			    ")|(" year "-0*" (utils.regexp.generate-number-upper-bound-regexp (- month 1)) "-\\d+"
			    ")|(" (utils.regexp.generate-number-upper-bound-regexp (- year 1)) "-\\d+-\\d+"
			    ")$"))))

(fn generate-plugin-lockdata [plugin lockdata]
	(let [pkg-name (nix.normalise-pkg-name plugin.name)
	      full-pkg-name (.. "vimPlugins." pkg-name)]

		(set lockdata.rev plugin.commit)
		; (set pkg.head (git.get-head-ref plugin.dir))
		; (set pkg.tag (git.get-checked-out-tag plugin.dir))

		(if (= (nix.get-pkg-revision full-pkg-name) plugin.commit)
			(set lockdata.src (.. "nixpkgs#" full-pkg-name))

			(set lockdata.src (-?> plugin.dir
				(get-version-restraint plugin.dir)
				(#(nix.get-pkg-versions full-pkg-name $1))
				(?. 1 :nixInstallable)))
				(#(if (= (nix.get-pkg-revision $1) plugin.commit) $1)))


		(when (and (not lockdata.src) plugin.url)
			(local nurldata (nix.nurl plugin.url plugin.commit))
			(set lockdata.hash nurldata.args.hash)
			(set lockdata.src (.. (get-src plugin.url nurldata.fetcher) "#" (plugin.commit:sub 1 8))))

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
				{:indent "  " :sort_keys true}))))

(fn update-plugins-locks [locks plugins]
	(each [_ plugin (ipairs plugins)]
		(local lockdata (or (?. locks plugin.name) {}))

		(when (and plugin.url plugin.dir (not plugin.commit))
			(set plugin.commit (git.get-checked-out-commit plugin.dir)))

		(when (and plugin.url plugin.commit (not (= plugin.commit lockdata.rev)))
			(tset locks plugin.name (generate-plugin-lockdata plugin lockdata))))
	locks)

(fn update-lockfile [path]
	(local lazy (require :lazy))
	(local plugins (lazy.plugins))

	(local locks (or (-> (read-lockfile path)
	                   (update-plugins-locks plugins))
	                 []))

	(write-lockfile path locks))

(vim.api.nvim_create_user_command "UpdateLockfile" (fn [] (update-lockfile plugins-lockfile-path)) {:bang true})

{: plugins-lockfile-path
 : read-lockfile
 : update-lockfile}
