#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="opencode"

create_session "$SESSION" \
"cd ~/Projects && echo 'OpenCode runtime'"

attach_or_switch "$SESSION"

