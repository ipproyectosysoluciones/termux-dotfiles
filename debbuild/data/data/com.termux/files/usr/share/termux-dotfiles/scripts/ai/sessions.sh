#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION=$(tmux ls 2>/dev/null | cut -d: -f1 | gum choose)

if [ -n "$SESSION" ]; then
    launch_in_window "$SESSION" "" "$SESSION"
fi
