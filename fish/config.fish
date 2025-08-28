# bass source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
# fish_add_path --prepend --global "$HOME/.nix-profile/bin"

set -g rpoc_cmd_duration_disabled 1

# Enable async-prompt debug logging
# set -g async_prompt_debug_log_enable 1
set -g async_prompt_debug_log_path $HOME/.cache/fish/prompt_debug.log

# Enable rpoc debug logging
# set -g rpoc_debug_log_enabled 1
set -g rpoc_debug_log_path $HOME/.cache/fish/prompt_debug.log
