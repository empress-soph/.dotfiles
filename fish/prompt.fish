set NORMAL (echo -e '\001')(set_color normal)(echo -e '\002')
set GREY (echo -e '\001')(set_color grey)(echo -e '\002')
set PURPLE (echo -e '\001')(set_color purple)(echo -e '\002')
set RED (echo -e '\001')(set_color red)(echo -e '\002')
set PINK (echo -e '\001')(set_color brmagenta)(echo -e '\002')
set DARKPINK (echo -e '\001')(set_color magenta)(echo -e '\002')
set GREEN (echo -e '\001')(set_color brgreen)(echo -e '\002')
set DARKGREEN (echo -e '\001')(set_color green)(echo -e '\002')
set YELLOW (echo -e '\001')(set_color bryellow)(echo -e '\002')
set DARKYELLOW (echo -e '\001')(set_color yellow)(echo -e '\002')
set ORANGE (echo -e '\001')(set_color yellow)(echo -e '\002')
set BLUE (echo -e '\001')(set_color blue)(echo -e '\002')
set CYAN (echo -e '\001')(set_color brcyan)(echo -e '\002')
set DARKCYAN (echo -e '\001')(set_color cyan)(echo -e '\002')
set WHITE (echo -e '\001')(set_color white)(echo -e '\002')

set -gx MYSQL_PS1 "$(printf '\001\033]133;A;\007\002%s:%s>\001\033]133;B;\007\002 ' "$(hostname)" '\d')"

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

	set -l stat     (git status 2>&1)
	set -l branch   (string match -rg 'On branch (.+)'                            $stat)
	set -l upstream (string match -rg 'Your branch is up to date with \'(.+)\'\.' $stat)
	set -l head     (test -z "$branch" && echo "$branch" || string match -rg 'HEAD detached at (.+)' $stat)

	set -l headstr ""
	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		set -l hash (git rev-parse --short HEAD)
		set headstr "$WHITE:$DARKCYAN$hash"
	end

	set -l upstreamstr ""
	if [ -n "$branch" ];
		set headstr "$CYAN$branch$headstr"
		if test "$rpoc_is_refreshing" != "1" 2>/dev/null
			if string match 'Your branch is ahead of' $stat;
				set upstreamstr "$GREEN^"
			else if string match 'Your branch is behind' $stat;
				set upstreamstr "$RED""v"
			else if string match -r '(This branch is \d+ commits? ahead and \d+ commits? behind)' $stat;
				set upstreamstr "$YELLOW~"
			end
		end

		# if git cherry "$branch" 'origin/HEAD' | string match '+';
		# 	set upstream_info "$upstream_info$CYAN[$RED!$CYAN]"
		# end

		# if [ -n "$upstream" ];
		# 	set -l cherry (git cherry "$branch" "$upstream" 2>&1)
		# end
	else
		set headstr "$RED""DETACHED$headstr"
	end

	set -l shortstat (git status --short 2>&1)

	set -l dirtystr ""
	if string match 'modified:' $stat;
		set -l unstaged  (string match 'Changes not staged for commit:' $stat)
		set -l staged    (string match 'Changes to be committed:'       $stat)
		set -l untracked (string match 'Untracked files'                $stat)

		if [ -n "$staged" ] && [ -n "$unstaged" ] || [ -n "$untracked" ];
			set dirtystr "$YELLOW*"
		else if [ -n "$staged" ];
			set dirtystr "$GREEN*"
		else if [ -n "$unstaged" ] || [ -n "$untracked" ];
			set dirtystr "$RED*"
		end
	end

	set -l diffstr ""
	if test "$rpoc_is_refreshing" != "1" 2>/dev/null
		set -l diff (git diff --shortstat)
		set -l inserted (string match -rg '(\d+)(?=\ insertions)' $diff)
		set -l deleted (string match -rg '(\d+)(?=\ deletions)' $diff)

		set -l untracked_count (string match -r '^\?\?' $shortstat | count)
		set -l added_count     (string match -r '^\ ?A' $shortstat | count)
		set -l modified_count  (string match -r '^\ ?M' $shortstat | count)
		set -l deleted_count   (string match -r '^\ ?D' $shortstat | count)

		set diffstr " $DARKGREEN$untracked_count$WHITE•$ORANGE$modified_count$WHITE•$RED$deleted_count$WHITE•$DARKCYAN$untracked_count"

		if [ -n "$inserted" ] || [ -n "$deleted" ];
			set diffstr "$diffstr ";
			if [ -n "$inserted" ]; set diffstr "$diffstr$GREEN$inserted+"; end
			if [ -n "$deleted"  ]; set diffstr "$diffstr$RED$deleted-";    end
		end
	end

	echo "$WHITE""g<$upstreamstr$headstr$dirtystr$diffstr$WHITE>"
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

function time_str
	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		set -l time (date +%H:%M:%S)
		echo -n (set_color normal)'('"$time"')'
	else
		echo -n (set_color normal)"(--:--:--) "
	end
end

function time_str_loading_indicator -a last
	echo -n (set_color normal)"(--:--:--) "
end

set -U async_prompt_functions fish_prompt
# set -U async_prompt_functions git_infostr
# shuts up an error in fish-refresh-prompt-on-cmd
# functions -c fish_prompt '__async_prompt_orig_fish_prompt'
# set -U async_prompt_functions git_infostr time_str
# set -U async_prompt_functions fish_prompt

function prompt_str
	set -l prompt '⋊> '

	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		echo -e (set_color normal)"$prompt"(set_color normal)(printf "\033]133;B;\007")
	else
		echo -e (set_color normal)"$prompt"(set_color normal)
	end
end

function fish_prompt
	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		echo -e (hoststr)(scmstr)" $DARKYELLOW"(pwd)"\n"(time_str)" "(prompt_str)
	else
		echo -e (hoststr)(scmstr)" $YELLOW"(custom_prompt_pwd)"\n"(prompt_str)
	end
 end

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
end

function cmd_duration_postexec --on-event fish_postexec
	set -l cmd_status "$status"

	set -l dur_str ""
	if test $CMD_DURATION
		set -l ms "$CMD_DURATION"
		set -l s  (math "$ms" / 1000)
		set -l m  (math "$s"  /   60)
		set -l h  (math "$m"  /   60)

		set -l dur ""

		# always show around 3 digits of accuracy
		if      [ "$h"  -gt "1"  ]; set dur (printf '%.0f' "$h")h(printf '%.0f' "$m")m
		else if [ "$m"  -gt "1"  ]; set dur (printf '%.0f' "$m")m(printf '%.0f' "$s")s
		else if [ "$s"  -gt "1"  ]; set dur (printf '%.2f' "$s")s
		else;                       set dur "$ms"ms
		end

		set dur_str '('"$GRAY$dur"')'
	end

	# set -l exitcode_str ""
	# if [ "$cmd_status" != "0" ];
	# 	set exitcode_str "- exited with status code: $cmd_status"
	# end

	echo -ne " ~> $dur_str"
end
