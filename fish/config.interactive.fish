# bind -M insert \t 'accept-autosuggestion'

bind --preset -M insert \n __rpoc_custom_event_enter_pressed
bind --preset -M insert \r __rpoc_custom_event_enter_pressed

set fish_color_command white

if [ -z "$NVIM" ]
	fish_vi_key_bindings
end

set -g PWD_IS_IN_GIT_REPO ''
function on_directory_change --on-variable PWD
	set -g PWD_IS_IN_GIT_REPO (git rev-parse --is-inside-work-tree 2> /dev/null)
end
