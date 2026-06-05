#!/data/data/com.termux/files/usr/bin/bash

run_startup_hooks() {

    [[ -n "${AUTO_START:-}" ]] || return 0

    local session="$1"

    echo "[ai] startup : $AUTO_START"

    tmux new-window \
        -t "$session" \
        -n startup \
        -c "$PROJECT_ROOT"

    tmux send-keys \
        -t "$session:startup" \
        "$AUTO_START" C-m
}

