# bind -M insert \t 'accept-autosuggestion'

bind --preset -M insert \n __rpoc_custom_event_enter_pressed
bind --preset -M insert \r __rpoc_custom_event_enter_pressed

set fish_color_command white

if [ -z "$NVIM" ]
	fish_vi_key_bindings
end

function reset_cwd_git_variables
	set -g CWD_GIT_REPO ""
	set -g CWD_GIT_REPO_status ""
	set -g CWD_GIT_REPO_shortstatus ""
	set -g CWD_GIT_REPO_diff ""
	set -g CWD_GIT_REPO_branch ""
	set -g CWD_GIT_REPO_upstream ""
	set -g CWD_GIT_REPO_head ""
	set -g CWD_GIT_REPO_hash ""
	set -g CWD_GIT_REPO_has_unstaged_changes ""
	set -g CWD_GIT_REPO_has_staged_changes ""
	set -g CWD_GIT_REPO_has_untracked_changes ""
	set -g CWD_GIT_REPO_lines_inserted ""
	set -g CWD_GIT_REPO_lines_deleted ""
	set -g CWD_GIT_REPO_untracked_files ""
	set -g CWD_GIT_REPO_added_files ""
	set -g CWD_GIT_REPO_modified_files ""
	set -g CWD_GIT_REPO_deleted_files ""
	set -g CWD_GIT_REPO_last_checkout_time ""
	set -g CWD_GIT_REPO_last_index_update_time ""
	set -g CWD_GIT_REPO_gh_prs ""
end

function update_cwd_git_variables_on_dir_change --on-variable PWD
	status --is-command-substitution; and return

	update_cwd_git_variables
end

function update_cwd_git_variables
	if [ -n "$__CWD_GIT_VARS_UPDATING" ]
		while true
			if [ -n "$__CWD_GIT_VARS_UPDATING" ]
				sleep 0.01
			end
		end

		return
	end

	set -g __CWD_GIT_VARS_UPDATING "1"

	set -g CWD_IN_GIT_REPO "$(git rev-parse --is-inside-work-tree 2> /dev/null)"

	if [ -z "$CWD_IN_GIT_REPO" ]
		reset_cwd_git_variables

		return
	end

	set -l repo "$(path normalize "$PWD/$(git rev-parse --show-cdup)")"
	if [ "$repo" != "$CWD_GIT_REPO" ]
		reset_cwd_git_variables
		set -g CWD_GIT_REPO "$repo"
	end

	set -l last_index_update_time "$(stat -f '%m' "$repo/.git/index")"
	set -l last_checkout_time "$CWD_GIT_REPO_last_checkout_time"

	set -l update_status ""

	if [ "$last_index_update_time" != "$CWD_GIT_REPO_last_index_update_time" ]
		set -g CWD_GIT_REPO_status "$(git -C "$repo" status 2>&1)"
		set -g CWD_GIT_REPO_shortstatus "$(git -C "$repo" status --short 2>&1)"
		set -g CWD_GIT_REPO_diff "$(git -C "$repo" diff --shortstat)"

		set last_checkout_time "$(git reflog --date=unix --grep-reflog='checkout: moving' -1 HEAD | string match -r '(?<=HEAD@\{)\d+(?=\})')"

		# catch freshly cloned repos
		if [ -z "$last_checkout_time" ]
			set last_checkout_time "$(git reflog --date=unix -1 HEAD | string match -e 'clone:' | string match -r '(?<=HEAD@\{)\d+(?=\})')"
		end
	end

	set -l stat "$CWD_GIT_REPO_status"
	set -l shortstat "$CWD_GIT_REPO_shortstatus"
	set -l diff "$CWD_GIT_REPO_diff"

	set -l branch "$CWD_GIT_REPO_branch"
	set -l upstream "$(string match -rg 'Your branch is up to date with \'(.+)\'\.' "$stat")"
	set -l head "$CWD_GIT_REPO_head"
	set -l hash "$CWD_GIT_REPO_hash"

	if [ "0$last_index_update_time" -ge "0$CWD_GIT_REPO_last_checkout_time" ]
		set branch "$(string match -rg 'On branch (.+)' "$stat")"
		set head   "$(test -z "$branch" && printf '%s' "$branch" || string match -rg 'HEAD detached at (.+)' "$stat")"
		set hash   "$(git rev-parse --short HEAD)"
	end

	if [ "0$last_checkout_time" -gt "0$CWD_GIT_REPO_last_checkout_time" ]
		if not git remote -v | string match -e -m1 'github.com' >/dev/null
			set -g CWD_GIT_REPO_gh_prs ""
		else if [ -n "$branch" ]
			set -g CWD_GIT_REPO_gh_prs "$(gh pr list --json="number,url,state" --head="$branch" --state="all" 2>/dev/null)"
		end

		set -g CWD_GIT_REPO_last_checkout_time "$last_checkout_time"
	end

	# untracked files don't update the index, so always update the variable
	set -l untracked_files "$(git -C "$repo" ls-files . --exclude-standard --others)"
	set -g CWD_GIT_REPO_untracked_files "$untracked_files"
	set -g CWD_GIT_REPO_has_untracked_changes "$(test "$(echo "$untracked_files" | count)" -gt 0 && printf 1)"

	if [ "$last_index_update_time" != "$CWD_GIT_REPO_last_index_update_time" ]
		# if string match -e 'modified:' "$stat"
		set -g CWD_GIT_REPO_has_unstaged_changes  "$(string match -qe 'Changes not staged for commit:' "$stat" && printf 1)"
		set -g CWD_GIT_REPO_has_staged_changes    "$(string match -qe 'Changes to be committed:'       "$stat" && printf 1)"
		# set -g CWD_GIT_REPO_has_untracked_changes "$(string match -qe 'Untracked files'                "$stat" && printf 1)"
		# end

		set -g CWD_GIT_REPO_lines_inserted "$(string match -rg '(\d+)(?=\ insertions)' "$diff")"
		set -g CWD_GIT_REPO_lines_deleted "$(string match -rg '(\d+)(?=\ deletions)' "$diff")"

		# set -g CWD_GIT_REPO_untracked_files_count "$(echo -e "$shortstat" | string match -r '^\?\?' | count)"
		set -g CWD_GIT_REPO_added_files     "$(echo -e "$shortstat" | string match -r '(?<=^\ ?A).*')"
		set -g CWD_GIT_REPO_modified_files  "$(echo -e "$shortstat" | string match -r '(?<=^\ ?M).*')"
		set -g CWD_GIT_REPO_deleted_files   "$(echo -e "$shortstat" | string match -r '(?<=^\ ?D).*')"

		set -g CWD_GIT_REPO_last_index_update_time "$last_index_update_time"
	end

	set -g CWD_GIT_REPO_status "$stat"
	set -g CWD_GIT_REPO_shortstatus "$shortstat"
	set -g CWD_GIT_REPO_diff "$diff"
	set -g CWD_GIT_REPO_branch "$branch"
	set -g CWD_GIT_REPO_upstream "$upstream"
	set -g CWD_GIT_REPO_head "$head"
	set -g CWD_GIT_REPO_hash "$hash"

	set -g __CWD_GIT_VARS_UPDATING ""
end
