#!/data/data/com.termux/files/usr/bin/bash

source ~/dotfiles/scripts/ai/utils.sh

SESSION="nvim"

create_session "$SESSION" "cd ~/Projects && nvim"

attach_or_switch "$SESSION"

