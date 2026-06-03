#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v tmux > /dev/null 2>&1 || [ -z "$TMUX" ]; then
  echo "Error: tmux is not running. Start tmux first, then use aip."
  exit 1
fi

tmux display-popup \
    -w 70% \
    -h 70% \
    -E "$SCRIPT_DIR/menu.sh"


