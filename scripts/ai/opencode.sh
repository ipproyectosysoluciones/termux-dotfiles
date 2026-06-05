#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

if ! command -v opencode > /dev/null 2>&1; then
    echo "opencode is not installed."
    echo "Install: pip install opencode or see docs/installation.md"
    exit 1
fi

SESSION="opencode"

launch_in_window "$SESSION" "cd ~/Projects && opencode" "opencode"
