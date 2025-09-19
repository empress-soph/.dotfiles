{ lib, pkgs, config, user, ... }:

{
	concatFiles = files:
		lib.concatStringsSep
			"\n\n"
			(builtins.filter
				(contents: builtins.stringLength contents != 0)
				(builtins.map (path: lib.trim (builtins.readFile path)) files));

	merge = sets: builtins.foldl' (a: b: lib.attrsets.recursiveUpdate a b) {} sets;

	fetchrepo = { url, rev, hash, ... }:
	let
	  matches = builtins.match "https?://github.com/([^/]+)/(.+).git" url;
	  github-user = lib.elemAt matches 0;
	  github-repo = lib.elemAt matches 1;
	in if matches != null then pkgs.fetchFromGitHub {
		owner = github-user;
		repo = github-repo;
		inherit rev hash;
	} else pkgs.fetchgit {
		inherit url rev hash;
	};

	fetchgit = { url, rev, hash, patches ? [], ... }:
	let
	  matches = builtins.match "https?://github.com/([^/]+)/(.+).git" url;
	  src = if matches != null then pkgs.fetchFromGitHub {
	    owner = lib.elemAt matches 0;
	    repo = lib.elemAt matches 1;
	    inherit rev hash;
	  } else pkgs.fetchgit {
	    inherit url rev hash;
	  };
	in if patches != [] then pkgs.applyPatches {
		inherit src patches;
	} else src;

	mkMutableSymlink = path: config.lib.file.mkOutOfStoreSymlink
		("${user.home}/.dotfiles" + lib.removePrefix (toString ./..) (toString path));

	linkFarm = let
		mkEntryFromDrv = drv:
			if lib.isDerivation drv then
				{ name = "${lib.getName drv}"; path = drv; }
			else
				drv;
	in name: entries:
		pkgs.linkFarm "${name}" (builtins.map mkEntryFromDrv entries);

	importLockfilePkgs = { lockfile, nixpkgsPath ? null }:
	let
		nixifyName = name: builtins.replaceStrings ["."] ["-"] name;

		locks = lib.attrsets.mapAttrsToList
			(name: value: lib.mergeAttrs value { inherit name; })
			(builtins.fromJSON (builtins.readFile lockfile));

	in builtins.listToAttrs
		(builtins.map (lock:
			let
				name = nixifyName lock.name;
				matches = builtins.match "^nixpgks/(.{8})#(.*)$" lock.src;
			in if matches != null then let
				nixpkgs-rev = lib.elemAt matches 0;
				pkg-path = lib.strings.splitString "." (lib.elemAt matches 1);
				_ = builtins.trace "${lib.version} ~ ${nixpkgs-rev} | ${lock.name}" true;
				nixpkgs = if builtins.match ''\d{2}\.\d{2}\.\d{8}\.${nixpkgs-rev}'' lib.version
					pkgs
				else (builtins.getFlake "nixpkgs/${nixpkgs-rev}").packages;
			in
				lib.attrsets.nameValuePair name
					lib.attrsets.getAttrFromPath pkg-path nixpkgs
			else let
				fetcherDomains = {
					fetchFromGithub    = "github.com/";
					fetchFromSourcehut = "git.sr.ht/~";
					fetchFromGitlab    = "gitlab.com/";
					fetchFromGitea     = "gitea.com/";
					fetchFromBitbucket = "bitbucket.org/";
					fetchFromGitiles   = "gerrit.googlesource.com/";
					fetchFromRepoOrCz  = "repo.or.cz/";
				};

				getFetcher = lock: let
					# TODO actually handle other types
					fetcherMatches = builtins.match "^(fetch[^:]+):.+$" lock.src;
					ownerRepoRevMatches = builtins.match "^fetch[^:]+:([^/]+)/([^/#]+)#(.+)$" lock.src;

					fetcherAttrs = if (fetcherMatches != null && ownerRepoRevMatches != null) then let 
						fetcher = lib.elemAt fetcherMatches 0;

						domain = if fetcherDomains ? fetcher then fetcherDomains.${fetcher} else null;

						owner = lib.elemAt ownerRepoRevMatches 0;
						repo = lib.elemAt ownerRepoRevMatches 1;
						rev = lib.elemAt ownerRepoRevMatches 2;

						src = if (domain && owner && repo) builtins.concatStringsSep "" ["https://" domain owner "/" repo];
					in {
						fn = fetcher;
						args = { inherit domain owner repo rev; };
					} else null;

				fetcher = getFetcher lock;
			in if fetcher != null then
				lib.attrsets.nameValuePair name
					(fetcher.fn fetcher.args)
			else null; # TODO support flakes?
		locks);
}
