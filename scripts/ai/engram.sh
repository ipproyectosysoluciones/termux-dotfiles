#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

if ! command -v engram > /dev/null 2>&1; then
    echo "engram is not installed."
    echo "Install: go install github.com/agentuity/engram@latest"
    exit 1
fi

SESSION="engram"

create_session "$SESSION" \
"engram"

attach_or_switch "$SESSION"

