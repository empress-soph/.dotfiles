{ lib, pkgs, ... }:

let
	nixifyName = name: builtins.replaceStrings ["."] ["-"] name;

	resolvePin = pin:
		let
			pkg-src = if pin ? "overrideSrc" then pin.overrideSrc else pin.src;
			in-nixpkgs = pin.src ? "installable" && (builtins.match "nixpkgs.*" pin.src.installable) != null;
		in if pkg-src ? "installable" then
			let
				matches = builtins.match "nixpkgs/(.+)#(.*)" pkg-src.installable;
				nixpkgs-rev = lib.elemAt matches 0;
				nixpkgs-path = lib.strings.splitString "." (lib.elemAt matches 1);
				nixpkgs =
					# TODO handle these properly
					if (builtins.match ''.*\.${nixpkgs-rev}'' lib.version) != null then
						null
					else
						# (import (pkgs.fetchFromGitHub {
						# 	owner = "NixOs";
						# 	repo = "nixpkgs";
						# 	rev = "c2ae88e";
						# 	hash = "sha256-erbiH2agUTD0Z30xcVSFcDHzkRvkRXOQ3lb887bcVrs=";
						# }) { system = "aarch64-darwin"; })
						builtins.getFlake "nixpkgs/${nixpkgs-rev}";
			in if nixpkgs != null then
				{
					inherit nixpkgs-path;
					pkg = lib.attrsets.getAttrFromPath nixpkgs-path nixpkgs;
				}
			else
				{ inherit nixpkgs-path; }
		else if pkg-src ? "fetcher" then
			let
				fetcher-path = lib.strings.splitString "." pkg-src.fetcher;
				fetcher = lib.attrsets.getAttrFromPath fetcher-path pkgs;
				src = (fetcher pkg-src.args);
				nixpkgs-path = lib.strings.splitString "." pkg-src.nixpkgsPath;
				version = "${pkg-src.version}-${(lib.toLower (lib.elemAt (builtins.match "(fetch(From)?)?(.+)" pkg-src.fetcher) 2))}";
				pkg = let
						name = pin.name;
						pname = pin.pname;
					in if in-nixpkgs then
						{
							inherit nixpkgs-path;
							override = {
								inherit version src;
							};
						}
					else
						{
							inherit nixpkgs-path;
							pkg =
								if pkg-src ? "builder" then let
									builder = lib.attrsets.getAttrFromPath
										(lib.strings.splitString "." pkg-src.builder)
										pkgs;
								in
									builder { inherit pname version src; }
								else
									src; # TODO mkDerivation?
						};
			in
				pkg
		else if pkg-src ? "flake" then
			builtins.getFlake pkg-src.flake
		else throw "Unknown src type";

	resolveOverride = pin:
		if pin ? "override" then
			pin.override
		else if pin ? "pkg" then
			pin.pkg
		else
			builtins.throw "Invalid pin";

	getPinsByNixpkgsPath = path: pins:
		(builtins.filter
			(pin: lib.lists.hasPrefix path pin.nixpkgs-path)
			pins);

	getNextPathComponents = path: pins:
		(lib.lists.unique
			(builtins.filter
				(component: component != null)

				(builtins.map
					(pin:
						if lib.lists.hasPrefix path pin.nixpkgs-path then
							(let
								remaining = lib.lists.removePrefix path pin.nixpkgs-path;
							in if remaining != [] then
								builtins.head remaining
							else
								null)
						else
							null)

					pins)));

	getOverrideForPath = prev: path: pins:
		let
			name = lib.lists.last path;
			pins' = getPinsByNixpkgsPath path pins;
			pin =
				if (builtins.length pins') == 1 then
					(builtins.head pins')
				else
					null;
		in if pin != null && pin.nixpkgs-path == path then
			(let
				resolved = resolveOverride pin;
			in if prev != null && builtins.hasAttr name prev then
				prev.${name}.overrideAttrs (old: resolved)
			else
				lib.makeExtensible (_: resolved))
		else if prev != null && builtins.hasAttr name prev then
			prev.${name}.extend (_: prev':
				builtins.listToAttrs (builtins.map
					(name':
						lib.attrsets.nameValuePair name'
							(getOverrideForPath prev' (path ++ [name']) pins'))

					(getNextPathComponents path pins')))
		else
			builtins.listToAttrs (builtins.map
				(name':
					lib.attrsets.nameValuePair name'
						(lib.makeExtensible (_: getOverrideForPath (path ++ [name']) pins')))

				(getNextPathComponents path pins'));
in
{
	import = lockfile-path:
		let
			raw-pins = lib.attrsets.mapAttrsToList
				(name: value: lib.mergeAttrs value { inherit name; })
				(builtins.fromJSON (builtins.readFile lockfile-path)).pkgs;

			pins = builtins.listToAttrs
				(builtins.map
					(raw-pin:
						let
							pname = nixifyName raw-pin.name;
							pin = resolvePin (raw-pin // { inherit pname; });
						in if pin != null then
							lib.attrsets.nameValuePair pname pin
						else null)

					raw-pins);

		in {
			overlay = (final: prev:
				let
					pins' = builtins.filter 
						(pin: (builtins.removeAttrs pin ["nixpkgs-path"]) != {})
						(builtins.map
							(name: pins.${name})
							(builtins.attrNames pins))
					;
				in (builtins.listToAttrs (builtins.map
					(name:
						lib.attrsets.nameValuePair name
							(getOverrideForPath prev [name] pins')) 

					(getNextPathComponents [] pins'))));

			pkgs = builtins.listToAttrs
				(builtins.map
					(name:
						(lib.attrsets.nameValuePair name
							(lib.attrsets.getAttrFromPath
								(pins.${name}.nixpkgs-path)
								pkgs)))

					(builtins.filter
						(pin: pin != null)
						(builtins.attrNames pins)));
		};
}
