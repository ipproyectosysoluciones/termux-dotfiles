#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/utils.sh"

SESSION="engram"

create_session "$SESSION" \
"cd ~/Projects && echo 'Engram memory runtime'"

attach_or_switch "$SESSION"

