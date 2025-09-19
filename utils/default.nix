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

		processLock = lock:
			let
				matches = builtins.match "^fetch([^:]+):([^/]+)/([^#]+)#(.+)$" lock.src;
			in if matches != null then
				let
					fetcherDomains = {
						fetchFromGithub    = "github.com/";
						fetchFromSourcehut = "git.sr.ht/~";
						fetchFromGitlab    = "gitlab.com/";
						fetchFromGitea     = "gitea.com/";
						fetchFromBitbucket = "bitbucket.org/";
						fetchFromGitiles   = "gerrit.googlesource.com/";
						fetchFromRepoOrCz  = "repo.or.cz/";
					};
					fetcher = lib.elemAt matches 0;
					owner = lib.elemAt matches 1;
					repo = lib.elemAt matches 2;
				in if fetcherDomains ? ${fetcher} then
					lib.mergeAttrs lock {
						inherit fetcher;
						src = builtins.concatStringsSep "" ["https://" fetcherDomains.${fetcher} owner "/" repo];
					}
				else 
					lib.mergeAttrs lock {
						inherit fetcher;
						src = "https://${owner}/${repo}";
					}
			else lock;

		locks = lib.attrsets.mapAttrsToList
			(name: value: lib.mergeAttrs value { inherit name; })
			(builtins.fromJSON (builtins.readFile lockfile));

		# nurlPkgs = builtins.listToAttrs (builtins.map (lock: pkgs.runCommand "${pkgs.nurl} ${parseSrc lock.src} ${lock.rev}") locks);
		fetch = lock: (lock.fetcher lock.fetcherArgs);

	in builtins.listToAttrs
		(builtins.map (lock:
			let
				name = nixifyName lock.name;
			in if builtins.trace lock (lib.strings.hasPrefix "nixpkgs" lock.src) then
				lib.attrsets.nameValuePair name (if nixpkgsPath != null then lib.attrsets.getAttrFromPath (nixpkgsPath ++ [name]) pkgs else pkgs.${name})
			else
				lib.attrsets.nameValuePair name (import (fetch lock)))
		locks);
}
