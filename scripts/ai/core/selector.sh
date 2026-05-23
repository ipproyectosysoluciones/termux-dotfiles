#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/core/registry.sh"

select_session() {

    local session

    session="$(
        list_sessions | gum filter \
            --prompt "Session > "
    )"

    echo "$session"
}

