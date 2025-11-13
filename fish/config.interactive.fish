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
