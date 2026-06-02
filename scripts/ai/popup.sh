#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux display-popup \
    -w 70% \
    -h 70% \
    -E "$SCRIPT_DIR/menu.sh"


