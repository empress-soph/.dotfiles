(local utils (require :lib.utils))
(local nix (require :lib.nix))
(local git (require :lib.git))

(local plugins-lockfile-path (.. (vim.fn.stdpath :config) "/nix-pkgs.lock"))

(fn get-src [original-url rev fetcher]
	(var url (-> original-url
	            (: :gsub "%.git$" "")
	            (: :gsub "^https?://" "")))

	(when fetcher
		(set url (if (= fetcher "fetchFromGitHub") (url:gsub "^github.com/" "")
		             (= fetcher "fetchFromSourcehut") (url:sub "^git.sr.ht/" "")
		             (= fetcher "fetchFromGitea") (url:sub "^gitea.com/" "")
		             (= fetcher "fetchFromGitLab") (url:sub "^gitlab.com/" "")
		             (= fetcher "fetchFromBitbucket") (url:sub "^bitbucket.org/" "")
		             (= fetcher "fetchFromGitiles") (url:sub "^gerrit.googlesource.com/" "")
		             (= fetcher "fetchFromRepoOrCz") (url:sub "^repo.or.cz/" "")
		             url))

		(set url (.. fetcher ":" url)))

	(when rev
		(set url (.. url "#" (rev:sub 1 8))))

	url)

(fn get-version-restraint [path]
	(local date-str (git.get-revision-date path :HEAD "%Y-%m-%d"))
	(local (year month day) (date-str:match "^(.-)%-(.-)%-(.-)$"))

	(.. "^("  year "-" month "-0*" (utils.regexp.generate-number-upper-bound-regexp day)
	    ")|(" year "-0*" (utils.regexp.generate-number-upper-bound-regexp (- month 1)) "-\\d+"
	    ")|(" (utils.regexp.generate-number-upper-bound-regexp (- year 1)) "-\\d+-\\d+"
	    ")$"))

(var nixpkgs-revision nil)

(fn generate-plugin-lockdata [plugin lockdata]
	(let [pkg-name (nix.normalise-pkg-name plugin.name)
	      full-pkg-name (.. "vimPlugins." pkg-name)
	      nix-version (nix.get-pkg-version full-pkg-name)
	      nix-revision (nix.get-pkg-revision full-pkg-name)]

		(set lockdata.rev plugin.commit)
		(set lockdata.url plugin.url)
		(set lockdata.head (git.get-head-ref plugin.dir))
		(set lockdata.dependencies plugin.dependencies)

		(when nix-version; (= nix-revision plugin.commit)
			; (set lockdata.version (or lockdata.version (nix.get-pkg-version full-pkg-name)))
			(set lockdata.src {:installable (.. "nixpkgs/" nixpkgs-revision "#" full-pkg-name)
			                   :hash (nix.get-pkg-hash full-pkg-name)
			                   :version nix-version}))
			;(set lockdata.hash (nix.get-pkg-hash full-pkg-name)))

		(when (and plugin.dir (or (not lockdata.src)
		                          (not (= nix-revision plugin.commit))))
			(let [installable (-?> plugin.dir
			                    (get-version-restraint plugin.dir)
			                    (#(nix.get-available-pkg-versions full-pkg-name $1))
			                    (?. 1 :nixInstallable))
			      commit (-?> installable (nix.get-pkg-revision))
			      version (-?> installable (nix.get-pkg-version))
			      hash (-?> installable (nix.get-pkg-hash))]
				(when (and installable commit hash (= commit plugin.commit))
					(let [src {:installable installable :hash hash :version version}]
						(if lockdata.src
							(set lockdata.overrideSrc src)
							(set lockdata.src src))))))
					; (set lockdata.version (or lockdata.version version))))

		(when (and plugin.url (or (not lockdata.src)
		                          (not (= nix-revision plugin.commit))))
			(let [nurldata (nix.nurl plugin.url plugin.commit)]
				(set nurldata.builder "vimUtils.buildVimPlugin")
				(set nurldata.version (or (git.get-checked-out-tag plugin.dir)
				                          (git.get-revision-date plugin.dir :HEAD "%Y-%m-%d")))
				(set nurldata.nixpkgsPath (or (-?> (?. lockdata.src :installable)
				                                (: :match "nixpgks/.*#(.+)"))
				                              full-pkg-name))
				(if lockdata.src
					(set lockdata.overrideSrc nurldata)
					(set lockdata.src nurldata))))
				; (set lockdata.hash (?. nurldata :args :hash))
				; (set lockdata.src (get-src plugin.url plugin.commit (?. nurldata :fetcher)))))

		lockdata))

(fn read-lockfile [path]
	; with-open breaks if the file doesn't exist, so do this bs to solve that
	(or (-?> (io.open path :r)
	      (#(with-open [lockfile $1] (lockfile:read :*a)))
	      (#(case (pcall vim.json.decode $1) (true json) json)))
	    {:meta {} :pkgs {}}))

(fn write-lockfile [path locks]
	(with-open [lockfile (io.open path :w)]
		(lockfile:write 
			(vim.json.encode locks
				{:indent "  " :sort_keys true}))))

(fn update-plugins-locks [locks plugins]
	(set nixpkgs-revision (nix.get-nixpkgs-revision))
	(each [_ plugin (ipairs plugins)]
		(local lockdata (or (?. locks :pkgs plugin.name) {}))

		(when (and plugin.url plugin.dir (not plugin.commit))
			(set plugin.commit (git.get-checked-out-commit plugin.dir)))

		(when (and plugin.url plugin.commit (not (= plugin.commit lockdata.rev)))
			(tset locks :pkgs plugin.name (generate-plugin-lockdata plugin lockdata))))
	locks)

(fn update-lockfile [path]
	(local lazy (require :lazy))
	(local plugins (lazy.plugins))

	(local lockfile (-> (read-lockfile path)
	                  (update-plugins-locks plugins)))

	(set lockfile.meta.version "0.0.0")
	(set lockfile.meta.nixpkgs (nix.get-pkg-version :lib))
	(set lockfile.meta.neovim  (nix.get-pkg-version :neovim))
	(set lockfile.meta.generated (os.time))

	(write-lockfile path lockfile))

(vim.api.nvim_create_user_command "UpdateNixpkgsLock" (fn [] (update-lockfile plugins-lockfile-path)) {:bang true})

{: plugins-lockfile-path
 : read-lockfile
 : update-lockfile}
