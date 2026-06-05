#!/data/data/com.termux/files/usr/bin/bash

build_layout() {

    local session="$1"

    ########################################
    # TMUX STABILIZATION
    ########################################

    sleep 0.3

    ########################################
    # GET CURRENT WINDOW
    ########################################

    local current_window

    current_window="$(tmux list-windows -t "$session" \
        -F '#I' | head -n 1)"

    ########################################
    # RENAME WINDOW
    ########################################

    tmux rename-window \
        -t "$session:$current_window" \
        "editor"

    ########################################
    # EDITOR
    ########################################

    tmux send-keys \
        -t "$session:editor" \
        "nvim" C-m

    ########################################
    # CLAUDE WINDOW
    ########################################

    tmux new-window \
        -t "$session" \
        -n "claude"

    tmux send-keys \
        -t "$session:claude" \
        "claude" C-m

    ########################################
    # FOCUS EDITOR
    ########################################

    tmux select-window \
        -t "$session:editor"
}
