(local utils (require :lib.utils))
(local nix (require :lib.nix))
(local git (require :lib.git))

(local plugins-lockfile-path (.. (vim.fn.stdpath :config) "/nix-pkgs.lock"))

(fn get-version-restraint [path]
	(local date-str (git.get-revision-date path :HEAD "%Y-%m-%d"))
	(local (year month day) (date-str:match "^(.-)%-(.-)%-(.-)$"))

	(.. "^("  year "-" month "-0*" (utils.regexp.generate-number-upper-bound-regexp day)
	    ")|(" year "-0*" (utils.regexp.generate-number-upper-bound-regexp (- month 1)) "-\\d+"
	    ")|(" (utils.regexp.generate-number-upper-bound-regexp (- year 1)) "-\\d+-\\d+"
	    ")$"))

(var nixpkgs-revision nil)

(fn generate-plugin-lockdata [plugin lockdata]
	(let [pkg-name      (nix.normalise-pkg-name plugin.name)
	      full-pkg-name (.. "vimPlugins." pkg-name)
	      nix-version   (nix.get-pkg-version full-pkg-name)
	      nix-revision  (nix.get-pkg-revision full-pkg-name)]

		(set lockdata.url plugin.url)
		(set lockdata.head (git.get-head-ref plugin.dir))
		(set lockdata.dependencies
			(if (and plugin.dependencies
			         (~= (next plugin.dependencies) nil))
				plugin.dependencies))

		(when nix-version ; (and nix-version) ; (= nix-revision plugin.commit))
			(set lockdata.src {:installable (.. "nixpkgs" "#" full-pkg-name)
			                   :version     nix-version}))

		; TODO handle these properly on the nix side of things
		(when (and plugin.dir (or (not lockdata.src)
		                          (~= nix-revision plugin.commit)
		                          (= lockdata.rev plugin.commit)))
			(let [installable (-?> plugin.dir
			                    (get-version-restraint plugin.dir)
			                    (#(nix.get-available-pkg-versions full-pkg-name $1))
			                    (?. 1 :nixInstallable))

			      commit  (-?> installable (nix.get-pkg-revision))
			      version (-?> installable (nix.get-pkg-version))
			      hash    (-?> installable (nix.get-pkg-hash))

			      src-data {:installable installable :version version}]

				(when (and installable commit hash (= commit plugin.commit))
					(if lockdata.src
						(set lockdata.src-override src-data)
						(set lockdata.src src-data)))))

		(when (and plugin.url (or (not lockdata.src)
		                          (~= nix-revision plugin.commit)
		                          (= lockdata.rev plugin.commit)))
			(let [nurldata (nix.nurl plugin.url plugin.commit)]
				(set nurldata.builder "vimUtils.buildVimPlugin")
				(set nurldata.version (or (git.get-checked-out-tag plugin.dir)
				                          (git.get-revision-date plugin.dir :HEAD "%Y-%m-%d")))
				(set nurldata.nixpkgs-path (or (-?> (?. lockdata :src :installable)
				                                (string.match "nixpgks/.*#(.+)"))
				                              full-pkg-name))
				(if lockdata.src
					(set lockdata.src-override nurldata)
					(set lockdata.src nurldata))))

		(set lockdata.rev plugin.commit)

		lockdata))

(fn read-lockfile [path]
	; with-open breaks if the file doesn't exist, so do this bs to solve that
	(or (-?> (io.open path :r)
	      (#(with-open [lockfile $1] (lockfile:read :*a)))
	      (#(case (pcall vim.json.decode $1) (true json) json)))
	    {:meta {} :pkgs {} :nixpkgs {} :neovim {}}))

(fn write-lockfile [path locks]
	(local lz-util (require :lazyvim.util))
	(with-open [lockfile (io.open path :w)]
		(lockfile:write 
			(lz-util.json.encode locks))))

(fn update-plugins-locks [locks plugins]
	(set nixpkgs-revision (nix.get-nixpkgs-revision))

	(local nixpkgs-overrides {})

	(each [_ plugin (ipairs plugins)]
		(var lockdata (or (?. locks :pkgs plugin.name) {}))

		(when (and plugin.url plugin.dir (not plugin.commit))
			(set plugin.commit (git.get-checked-out-commit plugin.dir)))

		(when (and plugin.url plugin.commit (not (= plugin.commit lockdata.rev)))
			(set lockdata (generate-plugin-lockdata plugin lockdata))

			(local nixpkgs-override-revision
				(-?> (?. lockdata :overrideSrc :installable)
				  (: :match "^nixpkgs/(.+)#.+$")))

			(when (and nixpkgs-override-revision (~= nixpkgs-override-revision nixpkgs-revision))
				(tset locks.nixpkgs.overrides nixpkgs-override-revision
					(or (?. locks :nixpkgs :overrides nixpkgs-override-revision)
					    (?. (nix.nurl "https://github.com/NixOS/nixpkgs" nixpkgs-override-revision) :args :hash))))

			(tset locks :pkgs plugin.name lockdata)))

	(set locks.nixpkgs.overrides
		 (if (~= (next nixpkgs-overrides) nil)
			 nixpkgs-overrides))

	locks)

(fn update-lockfile [path]
	(local lazy (require :lazy))
	(local plugins (lazy.plugins))

	(local lockfile (-> (read-lockfile path)
	                  (update-plugins-locks plugins)))

	(set lockfile.meta.generated (os.time))
	(set lockfile.meta.version "0.0.2")
	(set lockfile.nixpkgs.version (nix.get-pkg-version :lib))
	(set lockfile.neovim {:version (nix.get-pkg-version :neovim)})

	(write-lockfile path lockfile))

(vim.api.nvim_create_user_command "UpdateNixpkgsLock" (fn [] (update-lockfile plugins-lockfile-path)) {:bang true})

{: plugins-lockfile-path
 : read-lockfile
 : update-lockfile}
