use experimental :macros;

use JSON::Fast;

# sub generate-pkg-lockdata ($pkg, $lockdata)
# {
# 	my $pkg-name := normalize-pkg-name $pkg.alias;
# }

grammar PkgSpec
{
	token TOP {
		^ <.ws>
		$<url> = [ [ <protocol> '://' <domain> '/' ]? [<owner> '/']? <repo> ]
		[ '@' [ <head> ':' ]? <revision> ]?
		[ \s+ 'overrides' \s+ <override-pkg> ]?
		[ \s+ 'as' \s+ <alias> ]?
		[ \s+ 'depends on' \s+ <dependencies> ]?
		<.ws> $
	};

	token protocol { https? };
	token domain { <-[\s/]>+ };
	token owner { <-[\s/]>+ };
	token repo { <-[\s@]>+ };

	token head { <-[\s:]>+ };
	
	# token revision { <[0..9 a..f A..F]>+ };
	token revision { <-[\s]>+ };

	token override-pkg { <-[\s]>+ };
	token alias { <-[\s]>+ };
	token dependencies { <-[\s]>+ };
}

class PkgLock
{
	has Str $.head;
	has Str $.alias;
	has Str $.revision;
	has Hash $.src;
}

my $_nix-inputs-from = '/Users/jamie/.dotfiles';
sub nix-eval (Str $expr)
{
	# return qqx[ nix eval --inputs-from {$_nix-inputs-from} --raw {$expr} 2>/dev/null ];
	my $result = Promise.new;

	my $proc = Proc::Async.new('nix', 'eval', '--inputs-from', $_nix-inputs-from, '--raw', $expr);

	my $stdout = '';
	my $stderr = '';
	$proc.stdout.tap({ $stdout ~= $_ });
	$proc.stderr.tap({ $stderr ~= $_ });

	$proc.start.then({
		if ($_.result.exitcode == 0) {
			$result.keep($stdout);
		} else {
			$result.break($stderr);
		}
	});

	return $result;
}

sub nurl (Str $src, Str $revision)
{
	my $nurldata = Promise.new;

	my $proc = Proc::Async.new('nurl', '--json', $src, $revision);

	my $stdout = '';
	my $stderr = '';
	$proc.stdout.tap({ $stdout ~= $_ });
	$proc.stderr.tap({ $stderr ~= $_ });

	$proc.start.then({
		if ($_.result.exitcode == 0) {
			$nurldata.keep(from-json $stdout.trim);
		} else {
			$nurldata.break($stderr);
		}
	});

	return $nurldata;
}

class Pkg
{
	has Str $.name;
	has Str $.pkg is rw;
	has Str $.override-pkg is rw;
	has %.src;

	# has Hash $.lockdata is rw;
	has %.updates is rw;

	has %.nixpkg is rw = %();
	has Str @.dependencies is rw;

	has %!_lockdata;

	method from-spec (Str $name, %spec)
	{
		my %args = (
			src => %(),
		);

		%args<name> = %spec<owner>:exists ?? %spec<owner>.Str ~ '/' ~ $name !! $name;
		%args<pkg> = %spec<alias>:exists ?? %spec<alias>.Str !! $name;

		%args<override-pkg> = %spec<override-pkg>.Str if %spec<override-pkg>:exists;

		if (not %args<override-pkg>:exists) {
			my %override-pkg = from-json qqx[ nix-search --name *{$name} --json ];
			%args<override-pkg> = %override-pkg<package_attr_name> if %override-pkg<package_attr_name>:exists;
		}

		my $url = %spec<url>.Str;

		if not %spec<domain>:exists and %spec<owner>:exists and %spec<repo>:exists {
			$url = (%spec<protocol>:exists ?? %spec<protocol>.Str ~ '://' !! 'https://') ~ 'github.com/' ~ %spec<owner>.Str ~ '/' ~ %spec<repo>.Str;
		}

		if $url ~~ /^ (.*) '.git' $/ {
			$url = $0.Str if not qqx[ GIT_TERMINAL_PROMPT=0 git ls-remote $0 HEAD 2>/dev/null ] eq '';
		}

		%args<src><url> = $url;
		%args<src><head> = %spec<head> if %spec<head>:exists;
		%args<src><revision> = %spec<revision> if %spec<revision>:exists;

		# %args<dependencies> = %spec<dependencies> if %spec<dependencies>:exists;

		return self.new(|%args);
	}

	method from-lockdata (Str $name, %lockdata)
	{
		my %args = (
			src => %(),
			name => $name,
			pkg => %lockdata<pkg>,
			url => %lockdata<url>,
		);

		%args<override-pkg> = %lockdata<overrides> if %lockdata<overrides>:exists;

		%args<src><url> = %lockdata<url> if %lockdata<url>:exists;
		%args<src><head> = %lockdata<head> if %lockdata<head>:exists;
		%args<src><revision> = %lockdata<rev> if %lockdata<rev>:exists;

		%args<dependencies> = %lockdata<dependencies> if %lockdata<dependencies>:exists;

		%args<_lockdata> = %lockdata;

		return self.new(|%args);
	}

	method hydrate ()
	{
		my $result = Promise.new;

		my @promises = ();

		if not %.src<revision>:exists {
			%.src<revision> = qqx[ GIT_TERMINAL_PROMPT=0 git ls-remote {%.src<url>} {$.src<head> || 'HEAD'} 2>/dev/null ].split(/\s/)[0];
		}

		if $.override-pkg and (not %.nixpkg<version>:exists) {
			push @promises, nix-eval("nixpkgs#{$.override-pkg}.version").then({
				%.nixpkg<version> = $_.result.trim;
			});
		}

		if $.override-pkg and (not %.nixpkg<revision>:exists) {
			push @promises, nix-eval("nixpkgs#{$.override-pkg}.src.rev").then({
				my $rev = $_.result.trim;

				%.nixpkg<revision> = qqx[ GIT_TERMINAL_PROMPT=0 git ls-remote {%.src<url>} {$rev} 2>/dev/null ].split(/\s/)[0] || $rev;
			})
		}

		Promise.allof(@promises).then({ $result.keep; });

		return $result;
	}

	method update (%spec = Nil)
	{
		if (%spec) {
			$.pkg = %spec<alias>.Str if %spec<alias>:exists and %spec<alias> ne $.pkg;

			if %spec<head>:exists {
				%.src<head> = %spec<head>.Str;
			} else {
				%.src<head>:delete;
			}

			if %spec<revision>:exists {
				%.src<revision> = %spec<revision>.Str;
			} else {
				%.src<revision>:delete;
			}
		}
	}

	method !generate-lockdata ()
	{
		my $result = Promise.new;

		my @promises = ();

		$.hydrate.then({
			my %lockdata = %(
				pkg => $.pkg,
				url => %.src<url>,
			);

			%lockdata<head> = %.src<head> if %.src<head>:exists;
			%lockdata<rev> = %.src<revision> if %.src<revision>:exists;
			# %lockdata<dependencies> = $.dependencies if $.dependencies;

			if %.nixpkg<version>:exists {
				%lockdata<src> = %(
					installable => "nixpkgs#{$.override-pkg}",
					version => %.nixpkg<version>,
				);
			}

			if %.src<revision>:exists and ((not %.nixpkg<revision>:exists) or (%.nixpkg<revision> ne %.src<revision>)) {
				push @promises, nurl(%.src<url>, %.src<revision>).then({
					my %nurlsrc = $_.result;

					if %nurlsrc and %lockdata<src>:exists {
						%lockdata<src-override> = %nurlsrc;
					}
				});
			}

			Promise.allof(@promises).then({ $result.keep(%lockdata); });
		});

		return $result;
	}

	method lockdata ()
	{
		if not %!_lockdata {
			%!_lockdata = await self!generate-lockdata;
		}

		return %!_lockdata;
	}
}

# design:
# nxpkgs add 'folke/sidekick.nvim'
# nxpkgs add 'folke/sidekick.nvim@main:abcdefg'
# nxpkgs add 'folke/sidekick.nvim@main:abcdefg as vimPlugins.sidekick-nvim'
# nxpkgs --namespace vimPlugins add 'folke/sidekick.nvim@main:abcdefg as sidekick-nvim'
# nxpkgs --namespace vimPlugins add 'folke/sidekick.nvim@main:abcdefg as sidekick-nvim' --depends-on copilot-nvim

# my %*SUB-MAIN-OPTS = :named-anywhere;

class Lockfile
{
	has Str $.path;
	has Pkg %!_pkgs;

	method init (Str $path)
	{

	}

	method find ()
	{
		my $path = "$*CWD/nxpin.lock";

		my $dir = $*CWD;
		loop {
			my $f = "$dir/nxpin.lock";

			if $f.IO.e {
				$path = $f;
				last;
			}

			last if $dir.parent eq $dir;

			$dir = $dir.parent;
		}

		return self.new(|%(path => $path));
	}

	method !parse ()
	{
		%!_pkgs = %();

		if ($.path.IO.e) {
			my %lockdata = from-json(slurp $.path);

			for %lockdata<pkgs>.kv -> $name, %pkg-lockdata {
				%!_pkgs{$name} = Pkg.from-lockdata($name, %pkg-lockdata);
			}
		}
	}

	method pkgs ()
	{
		if not %!_pkgs {
			self!parse;
		}

		return %!_pkgs;
	}

	method add-pkg (%spec)
	{
		my $name = %spec<repo>.Str
			.subst(/\.git$/, '')
			.subst('.', '-')
		;

		my $id = %spec<owner>:exists ?? %spec<owner>.Str ~ '/' ~ $name !! $name;

		if %.pkgs{$id}:exists {
			%.pkgs{$id}.update(%spec);
		} else {
			%.pkgs{$id} = Pkg.from-spec($name, %spec);
		}
	}

	method generate-lockdata ()
	{
		my %lockdata = %(
			pkgs => %(),
		);

		for %.pkgs.kv -> $name, $pkg {
			%lockdata<pkgs>{$name} = $pkg.lockdata;
		}

		%lockdata<meta><generated> = now;

		return (to-json %lockdata, :pretty, :sorted-keys);
	}
}

multi MAIN (
	'add',
	+@pkgspec,
	# Str :$namespace?,
) {
	my $lockfile = Lockfile.find();

	my @specs = parse-pkgspecs @pkgspec;

	my @promises = ();

	for @specs -> %spec {
		$lockfile.add-pkg(%spec);
	}

	say $lockfile.generate-lockdata;
}

sub parse-pkgspecs (@args)
{
	my @specs;

	my %spec = ();

	while @args.elems {
		my $arg = @args.shift;

		my $parsed = PkgSpec.parse($arg);

		if $parsed {
			my %hash = $parsed.hash;

			push @specs, %hash;

			next;
		}

		die "Invalid package specification: $arg";
	}

	return @specs;
}

# macro exec (*@cmd)
# {
# 	quasi { qq "@cmd[]" }
# }

# say exec 'echo', 'hi';
# say exec 'echo', 'hello';
# say qqx[echo hi];

# my @test = ('echo', 'hi');
# say qq "@test[]"
