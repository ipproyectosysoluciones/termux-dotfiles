#!/data/data/com.termux/files/usr/bin/bash

source ~/dotfiles/scripts/ai/utils.sh

SESSION="gentle"

create_session "$SESSION" \
"cd ~/Projects && echo 'Gentle AI runtime'"

attach_or_switch "$SESSION"

