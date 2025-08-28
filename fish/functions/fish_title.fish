set -q argv[1]; or set argv fish
printf (whoami)

if [ -n "$IN_SSH_SESSION" ]
	printf "@"(hostname)
end

printf ": "

set -l wd (basename (pwd))
set -l repo ""

set -l repo_realpath ""

if [ -n "$PWD_IS_IN_GIT_REPO" ]
	set origin (git config --get remote.origin.url)
	if [ -n "$origin" ]
		set repo (basename -s .git (git config --get remote.origin.url))
	end
	set repo_path (git rev-parse --show-toplevel)
	set repo_realpath (realpath "$repo_path")

	if [ -z "$repo" ]
		set repo (basename "$repo_path")
	end

	printf "[$repo]"
end

if [ "$repo" != "$wd" ] && [ "$repo_realpath" != (pwd -P) ]
	if [ -n "$repo" ]
		printf ":"
	end

	if [ "$wd" = "$HOME" ]
		printf "~"
	else
		printf "$wd"
	end
end

set -l cmd (status current-command)
if [ "$cmd" != "fish" ]
	printf " ($cmd)"
end
