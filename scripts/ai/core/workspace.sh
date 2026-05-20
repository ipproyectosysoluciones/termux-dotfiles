#!/data/data/com.termux/files/usr/bin/bash

ensure_workspace() {
    local session="$1"
    local path="$2"

    if ! session_exists "$session"; then
        tmux new-session -d -s "$session" -c "$path"
    fi
}

attach_workspace() {
    local session="$1"

    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "$session"
    else
        tmux attach -t "$session"
    fi
}

