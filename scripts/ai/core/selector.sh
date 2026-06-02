#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/registry.sh"

select_session() {

    local session

    session="$(
        list_sessions | gum filter \
            --prompt "Session > "
    )"

    echo "$session"
}

