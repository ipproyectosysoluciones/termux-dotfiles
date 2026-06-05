#!/data/data/com.termux/files/usr/bin/bash

runtime_session_name() {

    local project="$1"

    echo "ai-${project}"
}

ensure_runtime_session() {

    local session="$1"

    if ! tmux has-session -t "$session" 2>/dev/null; then

        tmux new-session \
            -d \
            -s "$session"

    fi
}

attach_runtime_session() {

    local session="$1"

    tmux attach -t "$session"
}

