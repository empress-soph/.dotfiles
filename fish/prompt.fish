set NORMAL (echo -e '\001')(set_color normal)(echo -e '\002')
set GREY (echo -e '\001')(set_color grey)(echo -e '\002')
set PURPLE (echo -e '\001')(set_color purple)(echo -e '\002')
set RED (echo -e '\001')(set_color red)(echo -e '\002')
set PINK (echo -e '\001')(set_color brmagenta)(echo -e '\002')
set DARKPINK (echo -e '\001')(set_color magenta)(echo -e '\002')
set GREEN (echo -e '\001')(set_color brgreen)(echo -e '\002')
set DARKGREEN (echo -e '\001')(set_color green)(echo -e '\002')
set YELLOW (echo -e '\001')(set_color bryellow)(echo -e '\002')
set ORANGE (echo -e '\001')(set_color yellow)(echo -e '\002')
set BLUE (echo -e '\001')(set_color blue)(echo -e '\002')
set CYAN (echo -e '\001')(set_color brcyan)(echo -e '\002')
set DARKCYAN (echo -e '\001')(set_color cyan)(echo -e '\002')
set WHITE (echo -e '\001')(set_color white)(echo -e '\002')

# set -gx MYSQL_PS1 "$PINK"'\u'"$NORMAL"'@'"$GREEN"'\h'"$NORMAL"'['"$DARKPINK"'mysql'"$NORMAL"'] <'"$CYAN"'\T'"$YELLOW"'\d>'"$NORMAL"' mysql> '

set GREP (command -v grep)

# use grep for pcre as rg won't offer any performance improvement for that anyway
set PGREP (command -v pcre2grep)
if [ -z "$PGREP" ]
	set PGREP "$GREP --perl-regexp"
end

if [ -n (command -v rg) ]
	set GREP (command -v rg)
end

function uncolour_str -a str
	echo -n "$str" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g'
end

function make_env_string
	printf $WHITE'['$DARKPINK"$argv[1]"$WHITE

	if [ -n "$argv[2]" ]
		printf ":$DARKCYAN$argv[2]$WHITE"
	end

	printf ']'
end

function git_infostr
	if [ -z "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]
		 return
	end

	set -l gitstr ""

	set -l BRANCH (git branch --show-current)

	if [ -n "$BRANCH" ];
		set -l gitstatus (git status 2>&1 | tee)
		set -l cherry (git cherry $BRANCH 'origin/HEAD' 2>&1 | tee)

		set -l dirty      (echo "$gitstatus" | eval "env $GREP -F 'modified:'                     " > /dev/null 2>&1; echo "$status")
		set -l unstaged   (echo "$gitstatus" | eval "env $GREP -F 'Changes not staged for commit:'" > /dev/null 2>&1; echo "$status")
		set -l staged     (echo "$gitstatus" | eval "env $GREP -F 'Changes to be committed:'      " > /dev/null 2>&1; echo "$status")
		set -l untracked  (echo "$gitstatus" | eval "env $GREP -F 'Untracked files'               " > /dev/null 2>&1; echo "$status")
		set -l ahead      (echo "$gitstatus" | eval "env $GREP -F 'Your branch is ahead of'       " > /dev/null 2>&1; echo "$status")
		set -l behind     (echo "$gitstatus" | eval "env $GREP -F 'Your branch is behind'         " > /dev/null 2>&1; echo "$status")

		set -l mixed (echo "$gitstatus" | eval "env $GREP '(This branch is \d+ commits? ahead and \d+ commits? behind)'" > /dev/null 2>&1; echo "$status")

		set -l behind_origin (echo "$cherry" | eval "env $GREP -F '+'" > /dev/null 2>&1; echo "$status")

		set --local UPSTREAM ""
		set --local dirty_colour ""
		set --local dirty_symbol ""

		if [ "$ahead"         = "0" ]; set UPSTREAM "$GREEN^";               end
		if [ "$behind"        = "0" ]; set UPSTREAM "$REDv";                 end
		if [ "$mixed"         = "0" ]; set UPSTREAM "$YELLOW~";              end
		if [ "$behind_origin" = "0" ]; set UPSTREAM "$CYAN"["$RED"!"$CYAN"]; end
		if [ "$staged"        = "0" ]; set dirty_colour "$GREEN";            end

		if [ "$unstaged"  = "0" ] || [ "$untracked" = "0" ];
			set dirty_colour "$RED"
			if [ "$staged" = "0" ]; set dirty_colour "$YELLOW"; end
		end

		if [ "$dirty" = "0" ]; set dirty_symbol '*'; end

		set -l diff (git diff --shortstat)

		set -l inserted (echo "$diff" | eval "env $PGREP -o '\d+(?=\ insertions)'" 2> /dev/null)
		set -l deleted  (echo "$diff" | eval "env $PGREP -o '\d+(?=\ deletions)'"  2> /dev/null)

		set -l shortstatus (git status --short)
		# set -f shortstatus (git status --short)

		# Use sed to strip leading whitespace because solaris wc is stupid and adds leading whitespace
		set -l untracked (echo "$shortstatus" | eval "env $PGREP -o '^\?\?'" 2> /dev/null | wc -l | sed 's/^ *//')
		set -l added     (echo "$shortstatus" | eval "env $PGREP -o '^\ ?A'" 2> /dev/null | wc -l | sed 's/^ *//')
		set -l modified  (echo "$shortstatus" | eval "env $PGREP -o '^\ ?M'" 2> /dev/null | wc -l | sed 's/^ *//')
		set -l delfiles  (echo "$shortstatus" | eval "env $PGREP -o '^\ ?D'" 2> /dev/null | wc -l | sed 's/^ *//')

		set -l newf "$DARKGREEN$added"
		set -l untr "$DARKCYAN$untracked"
		set -l delf "$RED$delfiles"
		set -l mod  "$ORANGE$modified"

		set -l diffstr "$newf$WHITE•$mod$WHITE•$delf$WHITE•$untr"

		if [ -n "$inserted" ] || [ -n "$deleted" ]; set diffstr "$diffstr ";                end
		if [ -n "$inserted" ];                      set diffstr "$diffstr$GREEN$inserted+"; end
		if [ -n "$deleted"  ];                      set diffstr "$diffstr$RED$deleted-";    end

		set -l BRANCH_NAME "$CYAN$BRANCH"
		set -l DIRTY "$dirty_colour$dirty_symbol"
		set -l DIFFS "$diffstr"

		set gitstr "$WHITE""g<$UPSTREAM$BRANCH_NAME$DIRTY $DIFFS$WHITE>"
	end

	echo "$gitstr"
end

function git_infostr_loading_indicator -a last
	if [ -z "$PWD_IS_IN_GIT_REPO" ]
		 return
	end

	if [ -n $last ];
		echo "$GREY"(uncolour_str $last)
		return
	end

	echo "$WHITE""g<$CYAN…$WHITE>"
end

function scmstr
	echo " "(git_infostr)
end

function hoststr
	set -l user "$PINK"(whoami)
	set -l host ""

	if [ -n "$IN_SSH_SESSION" ]
		set host "$WHITE@$GREEN"(prompt_hostname)
	end

	if [ -n "$IN_VM" ]
		set host "$host"(make_env_string 'VM')
	end

	echo "$user$host"
end

function custom_prompt_pwd
	set -l dirs (string split '/' (fish_prompt_pwd_dir_length=0 prompt_pwd))

	for dir in $dirs[1..-4]
		if [ -z "$dir" ]
			continue
		end

		if [ "$dir" = "~" ]
			printf "$dir"
		# else if [ (string length "$dir") -gt "3" ]
		# 	printf /"$ORANGE"(string sub --length 3 "$dir")"$YELLOW"
		else if [ -n (string match -r -i 'a|e|i|o|u' (string sub --start 2 "$dir")) ]
			printf /"$ORANGE"(string sub --length 1 "$dir")(string replace -r -i -a 'a|e|i|o|u' '' (string sub --start 2 "$dir"))"$YELLOW"
		else
			printf /"$dir"
		end
	end

	for dir in $dirs[-3..-1]
		if [ "$dir" = "~" ]
			printf "$dir"
		else
			printf /"$dir"
		end
	end
end

set -U async_prompt_functions git_infostr

function time_str
	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		set -l time (date +%H:%M:%S)
		echo -n (set_color normal)'('$time') '
	else
		echo -n (set_color normal)""
	end
end

function prompt_str
	set -l prompt '⋊> '

	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		echo -e (set_color normal)"$prompt"(set_color normal)(printf "\033]133;B\007")
	else
		# echo -e (set_color cyan)"$prompt"(set_color normal)
		echo -e (set_color normal)"$prompt"(set_color normal)
	end
end

function fish_prompt
	# printf '%s\n%s' (hoststr)(scmstr)" $YELLOW"(custom_prompt_pwd)(set_color normal) '⋊> '
	
	echo -e (hoststr)(scmstr)" $YELLOW"(custom_prompt_pwd)"\n"(time_str)(prompt_str)
end

# function fish_prompt_loading_indicator
# 	printf '%s\n%s' (hoststr)" $YELLOW"(custom_prompt_pwd)(set_color normal) '⋊> '
# end

function fish_mode_prompt
	printf ""
end

function fish_right_prompt
	if [ -z "$NVIM" ]
		switch $fish_bind_mode
			case default
				set_color --bold red
				echo '[N]'
			case insert
				echo '   '
			case replace_one
				set_color --bold green
				echo '[R]'
			case visual
				set_color --bold brmagenta
				echo '[V]'
			case '*'
				set_color --bold red
				echo '[?]'
		end

		set -l show (echo "$mode" | grep -F '[I]'; echo "$status")
		if [ "$show" = "0" ]
			echo $mode
		end
	end

	# if test "$rpoc_is_refreshing" = "1" 2>/dev/null
	# 	set -l time (date +%H:%M)
	# 	echo " $GRAY$time"
	# end
end

function cmd_duration_postexec --on-event fish_postexec
	if test $CMD_DURATION
		set -l ms "$CMD_DURATION"
		set -l s  (math "$ms" / 1000)
		set -l m  (math "$s"  /   60)
		set -l h  (math "$m"  /   60)

		set -l dur ""

		# Goal: always show around 3 digits of accuracy
		if      [ "$h"  -gt "1"  ]; set dur (printf '%.0f' "$h")h(printf '%.0f' "$m")m
		else if [ "$m"  -gt "1"  ]; set dur (printf '%.0f' "$m")m(printf '%.0f' "$s")s
		else if [ "$s"  -gt "1"  ]; set dur (printf '%.2f' "$s")s
		else;                       set dur "$ms"ms
		end

		set -l dur_str "$GRAY$dur"

		# echo -n (printf "%-"(math $COLUMNS - (echo "$dur_str" | wc -c))"s%s↵" " " "$dur_str")
		echo -n "↪$dur_str"
	end
end

