#!/data/data/com.termux/files/usr/bin/bash

build_layout() {

    local session="$1"

    tmux rename-window -t "$session:0" "shell"

    tmux new-window \
        -t "$session" \
        -n "editor"

    tmux send-keys \
        -t "$session:editor" \
        "nvim" C-m

    tmux select-window \
        -t "$session:editor"
}

