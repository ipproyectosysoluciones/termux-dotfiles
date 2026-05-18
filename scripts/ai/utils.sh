#!/data/data/com.termux/files/usr/bin/bash

session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

attach_or_switch() {
    local session="$1"

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session"
    else
        tmux attach -t "$session"
    fi
}

create_session() {
    local session="$1"
    local command="$2"

    if ! session_exists "$session"; then
        tmux new-session -d -s "$session"

        if [ -n "$command" ]; then
            tmux send-keys -t "$session" "$command" C-m
        fi
    fi
}

