{ lib, pkgs, ... }:

let
	nixifyName = name: builtins.replaceStrings ["."] ["-"] name;

	resolvePin = pin: nixpkgs-overrides:
		let
			in-nixpkgs = pin.src ? installable && (builtins.match "nixpkgs#.*" pin.src.installable) != null;
			# pin-src = pin.src-override or pin.src;
			pin-src = pin.src;
		in if pin-src ? installable then
			let
				matches = builtins.match "nixpkgs/?(.*)#(.+)" pin-src.installable;
				nixpkgs-rev = lib.elemAt matches 0;
				nixpkgs-path = lib.strings.splitString "." (lib.elemAt matches 1);
				nixpkgs =
					# TODO handle these properly
					if
						nixpkgs-rev != ""
						&& (builtins.match ''.*\.${nixpkgs-rev}'' lib.version) == null
					then
						(import (pkgs.fetchFromGitHub {
							owner = "NixOs";
							repo = "nixpkgs";
							rev = nixpkgs-rev;
							hash = nixpkgs-overrides.${nixpkgs-rev};
						}) {})
					else
						null;
			in
				if nixpkgs != null then
				{
					inherit nixpkgs-path;
					pkg = lib.attrsets.getAttrFromPath nixpkgs-path nixpkgs;
				}
				else
					{ inherit nixpkgs-path; }
		else if pin-src ? "fetcher" then
			let
				fetcher-path = lib.strings.splitString "." pin-src.fetcher;
				fetcher = lib.attrsets.getAttrFromPath fetcher-path pkgs;
				src = (fetcher pin-src.args);
				nixpkgs-path = lib.strings.splitString "." pin-src.nixpkgs-path;
				version = "${pin-src.version}-${(lib.toLower (lib.elemAt (builtins.match "(fetch(From)?)?(.+)" pin-src.fetcher) 2))}";
				pkg = let
						name = pin.name;
						pname = pin.pname;
					in
						if in-nixpkgs then
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
									if pin-src ? builder then let
										builder = lib.attrsets.getAttrFromPath
											(lib.strings.splitString "." pin-src.builder)
											pkgs;
									in
										(builder { inherit pname version src; })
									else
										src; # TODO mkDerivation?
							}
					;
			in
				pkg
		else if pin-src ? "flake" then
			builtins.getFlake pin-src.flake
		else throw "Unknown src type";

	resolveOverride = pin:
		if pin ? override then
			pin.override
		else if pin ? pkg then
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
			pins-for-path = getPinsByNixpkgsPath path pins;
			pin =
				if (builtins.length pins-for-path) == 1 then
					(builtins.head pins-for-path)
				else
					null;
		in if pin != null then
			if pin.nixpkgs-path == path then
				(let
					resolved = resolveOverride pin;
				in if (resolved != null) && prev != null && (prev ? "${name}") then
					prev.${name}.overrideAttrs resolved
				else
					resolved)
					# lib.makeExtensible (_: resolved))
			else
				throw "Mismatched paths when resolving pin ${name}"
		else if prev != null && (prev ? "${name}") then
			prev.${name}.extend (_: prev':
				builtins.listToAttrs
					(builtins.filter
						(name-value-pair: name-value-pair.value != null)

						(builtins.map
							(name:
								let
									value = getOverrideForPath prev' (path ++ [name]) pins-for-path;
								in
								{ inherit name value; })

							(getNextPathComponents path pins-for-path))))
		else
			let
				override = builtins.listToAttrs
						(builtins.filter
							(name-value-pair: name-value-pair.value != null)

							(builtins.map
								(name:
									let
										value = getOverrideForPath null (path ++ [name]) pins-for-path;
									in
									{ inherit name value; })

								(getNextPathComponents path pins-for-path)));
			in if override != {} then
				override
			else null;
in
{
	import = lockfile-path:
		let
			lockdata = builtins.fromJSON (builtins.readFile lockfile-path);

			raw-pins = lib.attrsets.mapAttrsToList
				(name: value: lib.mergeAttrs value { inherit name; })
				lockdata.pkgs;

			pins = builtins.listToAttrs
				(builtins.map
					(raw-pin:
						let
							pname = nixifyName raw-pin.name;
							pin = resolvePin
								(raw-pin // { inherit pname; })

								(if lockdata.nixpkgs ? overrides then
									lockdata.nixpkgs.overrides
								else
									{});
						in if pin != null then
							{ name = pname; value = pin; }
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

					attrs = (builtins.listToAttrs (builtins.map
						(name:
							let
								value = (getOverrideForPath prev [name] pins');
							in { inherit name value; })

						(getNextPathComponents [] pins')))
					;
				in attrs);

			pkgs = builtins.listToAttrs
				(builtins.map
					(name:
						let
							value = (lib.attrsets.getAttrFromPath
								(pins.${name}.nixpkgs-path)
								pkgs);
						in { inherit name value; })

					(builtins.filter
						(pin: pin != null)
						(builtins.attrNames pins)));
		};
}
