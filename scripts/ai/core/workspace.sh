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

workspace_initialized() {

    local session="$1"

    tmux show-option \
        -t "$session" \
        -qv @ai_initialized 2>/dev/null
}

mark_workspace_initialized() {

    local session="$1"

    tmux set-option \
        -t "$session" \
        -q @ai_initialized "true"
}

