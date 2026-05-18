#!/data/data/com.termux/files/usr/bin/bash

source ~/dotfiles/scripts/ai/utils.sh

SESSION="opencode"

create_session "$SESSION" \
"cd ~/Projects && echo 'OpenCode runtime'"

attach_or_switch "$SESSION"

