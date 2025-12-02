{ lib, pkgs, utils, ... }:

let
	nixifyName = name: builtins.replaceStrings ["."] ["-"] name;

	nixpkgs-overrides = {};

	current-nixpkgs-rev = lib.elemAt (builtins.match ''.*\.([a-zA-Z0-9]+)'' lib.version) 0;

	resolvePin = pin: pkgs:
		let
			pin-src = pin.src-override or pin.src;
			nixpkgs-path = pin.nixpkgs-path;
		in if pin-src ? installable then
			let
				nixpkgs =
					# TODO handle these properly
					if pin.nixpkgs-rev != null
						&& pin.nixpkgs-rev != current-nixpkgs-rev
					then
						(import (pkgs.fetchFromGitHub {
							owner = "NixOs";
							repo = "nixpkgs";
							rev = pin.nixpkgs-rev;
							hash = nixpkgs-overrides.${pin.nixpkgs-rev};
						}) {})
					else
						null;
			in
				if nixpkgs != null then
				{
					inherit nixpkgs-path;
					version = pin-src.version;
					pkg = lib.attrsets.getAttrFromPath nixpkgs-path nixpkgs;
				}
				else
				{
					inherit nixpkgs-path;
					version = pin-src.version;
				}
		else if pin-src ? fetcher then
			let
				fetcher-path = lib.strings.splitString "." pin-src.fetcher;
				fetcher = lib.attrsets.getAttrFromPath fetcher-path pkgs;
				src = fetcher pin-src.args;
				version = "${pin-src.version}-${(lib.toLower (lib.elemAt (builtins.match "(fetch(From)?)?(.+)" pin-src.fetcher) 2))}";
				pkg = let
						name = pin.name;
						pname = pin.pname;
					in
						if (lib.attrsets.attrByPath nixpkgs-path false pkgs) != false then
							{
								inherit nixpkgs-path;
								version = pin-src.version;
								override = {
									inherit version src;
								};
							}
						else
							{
								inherit nixpkgs-path;
								version = pin-src.version;
								pkg =
									if pin-src ? builder then let
										builder = lib.attrsets.getAttrFromPath
											(lib.strings.splitString "." pin-src.builder)
											pkgs;
									in
										builder { inherit pname version src; }
									else
										src; # TODO mkDerivation?
							}
					;
			in
				pkg
		# else if pin-src ? flake then
		# 	{
		# 		nixpkgs-path = lib.strings.splitString "." pin-src.nixpkgs-path;
		# 		version = pin-src.version;
		# 		pkg = builtins.getFlake pin-src.flake;
		# 	}
		else
			throw "Unknown src type";

	resolveOverride = pin:
		let
			resolved =
				if pin ? override then
					pin.override
				else if pin ? pkg then
					pin.pkg
				else
					builtins.throw "Invalid pin";
		in
			if resolved != {} then
				resolved
			else
				null;

	getPinsByNixpkgsPath = path: pins:
		(builtins.filter
			(pin: lib.lists.hasPrefix path pin.nixpkgs-path)
			pins);

	getNextPathComponents = path: pins-list:
		(lib.lists.unique
			(builtins.filter
				(component: component != null)

				(builtins.map
					(pin:
						if lib.lists.hasPrefix path pin.nixpkgs-path then
							(let
								remaining = lib.lists.removePrefix path pin.nixpkgs-path;
							in
								if remaining != [] then
									builtins.head remaining
								else
									null)
						else
							null)

					pins-list)));

	getOverrideForPath = pkgs: parent: path: pins-list:
		let
			name = lib.lists.last path;
			pins-for-path = getPinsByNixpkgsPath path pins-list;
			unresolved-pin =
				if (builtins.length pins-for-path) == 1
					&& (builtins.head pins-for-path).nixpkgs-path == path
				then
					(builtins.head pins-for-path)
				else
					# throw ''Mismatched nixpkgs path when resolving at override path "${lib.concatStringsSep "/" path}"; found pin with nixpkg path "${lib.concatStringsSep "/" pin.nixpkgs-path}"''
					null;
			pin = if unresolved-pin != null then resolvePin unresolved-pin pkgs else null;
			override-attrs =
				if pin != null then
					resolveOverride pin
				else
					null;
		in
			if parent != null && (parent ? ${name}) && override-attrs != null then
				parent.${name}.overrideAttrs override-attrs
			else if parent != null && (parent ? ${name}) && (builtins.length pins-for-path > 0) then
				parent.${name}.extend (_: prev:
					builtins.listToAttrs
						(builtins.filter
							({ name, value }: value != null && value != {})

							(builtins.map
								(name: {
									inherit name;
									value = getOverrideForPath pkgs prev (path ++ [name]) pins-for-path;
								})

								(getNextPathComponents path pins-for-path))))
			else if parent != null && override-attrs != null then
				override-attrs
			else
				let
					override = builtins.listToAttrs
							(builtins.filter
								({ value }: value != null)

								(builtins.map
									(name: {
										inherit name;
										value = getOverrideForPath pkgs null (path ++ [name]) pins-for-path;
									})

									(getNextPathComponents path pins-for-path)));
				in
					if override != {} then
						override
					else
						null
	;
in
{
	import = lockfile-path:
		let
			lockdata = builtins.fromJSON (builtins.readFile lockfile-path);

			pins = utils.filterMapAttrs
				(name: pin: pin != null)

				(name: raw-pin:
					let
						pname = nixifyName name;
						# in-nixpkgs = raw-pin.src ? installable
						# 	&& (builtins.match "nixpkgs#.*" raw-pin.src.installable) != null;
						matches =
							if raw-pin.src ? installable then
								builtins.match "nixpkgs/?(.*)#(.+)" raw-pin.src.installable
							else null;
						# nixpkgs-rev = (lib.elemAt (builtins.match ''.*\.([a-zA-Z0-9]+)'' lib.version) 1)
						nixpkgs-rev = if matches != null then lib.elemAt matches 0 else null;
						nixpkgs-path = lib.strings.splitString "."
							(if matches != null then
								lib.elemAt matches 1
							else
								(raw-pin.src-override or raw-pin.src).nixpkgs-path)
						;
					in
						(raw-pin // {
							inherit name pname nixpkgs-path;
							nixpkgs-rev = if nixpkgs-rev == "" then current-nixpkgs-rev else nixpkgs-rev;
						}))

				lockdata.pkgs
			;

			pins-list = lib.attrsets.mapAttrsToList
				(name: pin: pin)
				pins
			;

			override-pins-list = builtins.filter
				(pin: pin.nixpkgs-rev != current-nixpkgs-rev)
				pins-list
			;
		in {
			overlay = final: prev:
				let next = getNextPathComponents [] override-pins-list; in
				builtins.listToAttrs
					(builtins.filter
						# ({ name, value }: value != null && value != {})
						({ name, value }: true)

						(builtins.map
							(name: {
								inherit name;
								value = getOverrideForPath prev prev [name] override-pins-list;
							})

							next))
			;

			pins = builtins.mapAttrs
				(name: pin: {
					name = lib.concatStringsSep "." pin.nixpkgs-path;
					pname = pin.pname;
					version = pin.version;
					is-override = pin ? override;
				})

				pins
			;

			pkgs = utils.filterMapAttrs
				(name: pkg: pkg != null)

				(name: pin: lib.attrsets.getAttrFromPath
					pin.nixpkgs-path
					pkgs)

				pins
			;
		};
}
