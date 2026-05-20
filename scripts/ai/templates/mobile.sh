#!/data/data/com.termux/files/usr/bin/bash

build_layout() {

    local session="$1"

    tmux rename-window -t "$session:0" "editor"

    tmux send-keys \
        -t "$session:editor" \
        "nvim" C-m

    tmux new-window \
        -t "$session" \
        -n "claude"

    tmux send-keys \
        -t "$session:claude" \
        "claude" C-m

    tmux select-window \
        -t "$session:editor"
}

