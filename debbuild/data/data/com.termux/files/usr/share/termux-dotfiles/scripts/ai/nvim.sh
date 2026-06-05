#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="nvim"

launch_in_window "$SESSION" "cd ~/Projects && nvim" "nvim"
