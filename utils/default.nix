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
}
