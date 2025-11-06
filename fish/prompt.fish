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

# set -gx MYSQL_PS1 "$PINK"'\u'"$NORMAL"'@'"$GREEN"'\h'"$NORMAL"'['"$DARKPINK"'mysql'"$NORMAL"'] <'"$CYAN"'\T'"$YELLOW"'\d>'"$NORMAL"' mysql> '

function uncolour_str -a str
	echo -n "$str" | sed -r 's/\x1B\[[0-9;]*[JKmsu]//g'
end

function _prompt_make_env_string
	printf $WHITE'['$DARKPINK"$argv[1]"$WHITE

	if [ -n "$argv[2]" ]
		printf ":$DARKCYAN$argv[2]$WHITE"
	end

	printf ']'
end

function _prompt_git_infostr
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	update_cwd_git_variables

	set -l stat "$CWD_GIT_REPO_status"
	set -l hash "$CWD_GIT_REPO_hash"
	set -l branch "$CWD_GIT_REPO_branch"

	set -l headstr ""
	if [ "$rpoc_is_refreshing" = "1" ]
		set -l hash "$(git rev-parse --short HEAD)"
		set headstr "$WHITE:$DARKCYAN$hash"
	end

	set -l upstreamstr ""
	if [ -n "$branch" ]
		set headstr "$CYAN$branch$headstr"
		if [ "$rpoc_is_refreshing" != "1" ]
			if string match 'Your branch is ahead of' "$stat"
				set upstreamstr "$GREEN^"
			else if string match 'Your branch is behind' "$stat";
				set upstreamstr "$RED""v"
			else if string match -r '(This branch is \d+ commits? ahead and \d+ commits? behind)' "$stat";
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
	printf '%s' "$upstreamstr"
	printf '%s' "$headstr"
end

function _prompt_git_infostr_loading_indicator -a last
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	if [ -n "$last" ] && [ "$(realpath "$CWD_GIT_REPO")" = "$__prompt_git_repo" ]
		printf '%s' "$GREY$(uncolour_str $last)"

		return
	end

	printf '%s' "$CYAN…"
end

function _prompt_git_dirtystr
	set -l unstaged "$CWD_GIT_REPO_has_unstaged_changes"
	set -l staged "$CWD_GIT_REPO_has_staged_changes"
	set -l untracked "$CWD_GIT_REPO_has_untracked_changes"

	if [ -n "$staged" ] && [ -n "$unstaged" ] || [ -n "$untracked" ]
		printf '%s' "$YELLOW*"
	else if [ -n "$staged" ]
		printf '%s' "$GREEN*"
	else if [ -n "$unstaged" ] || [ -n "$untracked" ]
		printf '%s' "$RED*"
	end
end

function _prompt_git_diffstr
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	update_cwd_git_variables

	set -l inserted_lines "$CWD_GIT_REPO_lines_inserted"
	set -l deleted_lines  "$CWD_GIT_REPO_lines_deleted"

	set -l added_files     "$CWD_GIT_REPO_added_files"
	set -l modified_files  "$CWD_GIT_REPO_modified_files"
	set -l deleted_files   "$CWD_GIT_REPO_deleted_files"
	set -l untracked_files "$CWD_GIT_REPO_untracked_files"

	set -l added_files_count     "$(test -n "$added_files"     && echo "$added_files"     | count || printf '0')"
	set -l modified_files_count  "$(test -n "$modified_files"  && echo "$modified_files"  | count || printf '0')"
	set -l deleted_files_count   "$(test -n "$deleted_files"   && echo "$deleted_files"   | count || printf '0')"
	set -l untracked_files_count "$(test -n "$untracked_files" && echo "$untracked_files" | count || printf '0')"

	# if this returns too fast it isn't actually displayed
	# so introduce a small unnoticeable delay
	sleep 0.03

	set -l sep "$WHITE•"
	printf " %s$sep%s$sep%s$sep%s" \
		"$DARKGREEN$added_files_count" \
		"$ORANGE$modified_files_count" \
		"$RED$deleted_files_count" \
		"$DARKCYAN$untracked_files_count"

	if [ -n "$inserted_lines" ] || [ -n "$deleted_lines" ]
		printf ' '
		if [ -n "$inserted_lines" ]; printf '%s' "$GREEN$inserted_lines+"; end
		if [ -n "$deleted_lines"  ]; printf '%s' "$RED$deleted_lines-";    end
	end
end

function _prompt_git_diffstr_loading_indicator -a last
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	# if [ -n "$last" ] && [ "$dirprev[-1]" = "$PWD" ]
	# 	printf '%s' "$GREY$(uncolour_str $last)"
	#
	# 	return
	# end

	if [ -n "$last" ] && [ "$(realpath "$CWD_GIT_REPO")" = "$__prompt_git_repo" ]
		printf '%s' "$GREY$(uncolour_str $last)"

		return
	end

	printf ' %s' "$GREY…"
end

# "•" + "'"$GREY"'" +
function _prompt_gh_prstr
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	update_cwd_git_variables

	set -l ghprs "$CWD_GIT_REPO_gh_prs"

	if [ -n "$ghprs" ]
		set -l ghprs_jqfilter "$(echo '
			map(
				(
					if .state == "MERGED" then
						"'"$(set_color magenta)"'"
					else
						if .state == "CLOSED" then
							"'"$(set_color red)"'"
						else
							"'"$(set_color normal)"'"
						end
					end
				)
				+ "\u001b]8;;" + .url + "\u001b\\\"
				+ "#\(.number)"
				+ "\u001b]8;;\u001b\\\"
			) | .[]
		')"

		# if this returns too fast it isn't actually displayed
		# so introduce a small unnoticeable delay
		sleep 0.07

		set -l prstr "$(echo "$ghprs" | jq -r "$ghprs_jqfilter" | string join ' ')"

		if [ -n "$prstr" ]
			printf ' %s' "$prstr"
		end
	end
end

function _prompt_gh_prstr_loading_indicator -a last
	if [ -z "$CWD_IN_GIT_REPO" ]
		 return
	end

	if [ -n "$last" ] && [ "$CWD_GIT_REPO" = "$__prompt_git_repo" ]
		printf '%s' "$GREY$(uncolour_str $last)"

		return
	end
end

set -g __prompt_git_repo ""
function _prompt_scmstr
	if [ -n "$CWD_IN_GIT_REPO" ]
		set -g __prompt_git_repo "$(git rev-parse --show-toplevel)"

		printf '%s' " $WHITE"'g<'
		printf '%s' "$(_prompt_git_infostr)"
		if [ "$rpoc_is_refreshing" = "1" ]
			printf '%s' "$GREY:$DARKCYAN$CWD_GIT_REPO_hash"
			# printf '%s' "$(git_dirtystr)"
		end
		printf '%s' "$(_prompt_git_diffstr)"
		printf '%s' "$WHITE>"
		printf '%s' "$(_prompt_gh_prstr)"
	end
end

function _prompt_hoststr
	set -l user "$PINK$(whoami)"
	set -l host ""

	if [ -n "$IN_SSH_SESSION" ]
		set host "$WHITE@$GREEN$(prompt_hostname)"
	end

	if [ -n "$IN_VM" ]
		set host "$host$(_prompt_make_env_string 'VM')"
	end

	printf '%s%s' "$user" "$host"
end

function prompt_pwd_abbrev
	set -l dirs (string split '/' (fish_prompt_pwd_dir_length=0 prompt_pwd))

	for dir in $dirs[1..-4]
		if [ -z "$dir" ]
			continue
		end

		if [ "$dir" = "~" ]
			printf "$dir"
		# else if [ (string length "$dir") -gt "3" ]
		# 	printf /"$ORANGE"(string sub --length 3 "$dir")"$YELLOW"
		else if [ -n "$(string match -r -i 'a|e|i|o|u' "$(string sub --start 2 "$dir")")" ]
			printf /"$ORANGE$(string sub --length 1 "$dir")$(string replace -r -i -a 'a|e|i|o|u' '' "$(string sub --start 2 "$dir")")$YELLOW"
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

function _prompt_time_str
	if [ "$rpoc_is_refreshing" = "1" ]
		set -l time "$(date +%H:%M:%S)"
		printf '%s' "$(set_color normal)($time)"
	else
		printf '%s' "$(set_color normal)(--:--:--)"
	end
end

# function time_str_loading_indicator -a last
# 	# echo ""
# 	# echo -n (set_color normal)"(--:--:--) "
# end

function _prompt_str
	set -l prompt '⋊> '

	if [ "$rpoc_is_refreshing" = "1" ]
		printf '%s' "$(set_color normal)$prompt$(set_color normal)$(printf '\033]133;B;\007')"
	else
		# echo -e (set_color cyan)"$prompt"(set_color normal)
		printf '%s' "$(set_color normal)$prompt$(set_color normal)"
	end
end

function fish_prompt
	# printf '%s\n%s' (hoststr)(scmstr)" $YELLOW"(custom_prompt_pwd)(set_color normal) '⋊> '

	if test "$rpoc_is_refreshing" = "1" 2>/dev/null
		printf '%s%s %s\n%s %s' "$(_prompt_hoststr)" "$(_prompt_scmstr)" "$DARKYELLOW$(pwd)" "$(_prompt_time_str)" "$(_prompt_str)"
	else
		# echo -e (hoststr)(scmstr)" $YELLOW"(custom_prompt_pwd)"\n"(prompt_str)
		printf '%s%s %s\n%s' "$(_prompt_hoststr)" "$(_prompt_scmstr)" "$YELLOW$(prompt_pwd_abbrev)" "$(_prompt_str)"
	end
 end

# shuts up an error in fish-refresh-prompt-on-cmd from not
# having fish_prompt as an async prompt function
functions -c fish_prompt '__async_prompt_orig_fish_prompt'
set -U async_prompt_functions _prompt_git_infostr _prompt_git_diffstr _prompt_gh_prstr
set -U async_prompt_inherit_variables all

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

function _prompt_cmd_duration_postexec --on-event fish_postexec
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

	set -l exitcode_str ""
	if [ "$cmd_status" != "0" ];
		set exitcode_str (set_color red)"$cmd_status"(set_color normal)" "
	end

	printf '%s' " ~> $dur_str"
end
