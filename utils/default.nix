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
			let entry =
				if lib.isDerivation drv then
					{ name = "${lib.getName drv}"; path = drv; }
				else if (drv ? "name") && (drv ? "outPath") then
					{ name = drv.name; path = drv.outPath; }
				else
					drv;
			in builtins.trace "entry: ${entry.name} ${entry.path}" entry;
	in name: entries:
		pkgs.linkFarm "${name}" (builtins.map mkEntryFromDrv entries);

	importLockfile = lockfile:
	let
		nixifyName = name: builtins.replaceStrings ["."] ["-"] name;

		locks = lib.attrsets.mapAttrsToList
			(name: value: lib.mergeAttrs value { inherit name; })
			(builtins.fromJSON (builtins.readFile lockfile)).pkgs;

		resolvePkg = lock:
			let
				pname = nixifyName lock.name;
				pkg-src = lock.overrideSrc or lock.src;
				# pkg-src = lock.src;


			in if pkg-src ? "installable" then let
				matches = builtins.match "nixpkgs/(.+)#(.*)" pkg-src.installable;
				nixpkgs-rev = lib.elemAt matches 0;
				pkg-path = lib.strings.splitString "." (lib.elemAt matches 1);
				nixpkgs =
					if (builtins.match ''.*\.${nixpkgs-rev}'' lib.version) != null then
						pkgs
					else
						(builtins.getFlake "nixpkgs/${nixpkgs-rev}");
			in
				lib.attrsets.getAttrFromPath pkg-path nixpkgs


			else if pkg-src ? "fetcher" then let
				fetcher = lib.attrsets.getAttrFromPath (lib.strings.splitString "." pkg-src.fetcher) pkgs;
				src = (fetcher pkg-src.args);
				version = "${pkg-src.version}-${(builtins.replaceString ["fetch" "fetchFrom"] ["" ""] pkg-src.fetcher)}";
				pkg =
					if pkg-src ? "builder" then let 
						builder = lib.attrsets.getAttrFromPath (lib.strings.splitString "." pkg-src.builder) pkgs;
					in
						(builder { inherit pname version src; })
					else
						src;
			in
				pkg


			else if pkg-src ? "flake" then
				builtins.getFlake pkg-src.flake
			else throw "Unknown src type";

	in builtins.listToAttrs
		(builtins.filter (pkg: pkg != null)
			(builtins.map
				(lock:
					let
						pname = nixifyName lock.name;
						pkg = resolvePkg lock;
					in if pkg != null then
						lib.attrsets.nameValuePair (builtins.trace "${pname}: ${pkg}" pname) pkg
					else null)
				locks));
}
