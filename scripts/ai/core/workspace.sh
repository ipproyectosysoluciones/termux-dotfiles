#!/data/data/com.termux/files/usr/bin/bash

WORKSPACE_DB="$HOME/.ai/workspaces"

mkdir -p "$WORKSPACE_DB"

########################################
# METADATA
########################################

ensure_workspace_metadata() {

    mkdir -p "$WORKSPACE_DB"
}

load_workspace_metadata() {

    return 0
}

########################################
# WORKSPACE INIT STATE
########################################

workspace_initialized() {

    local session="$1"

    if [[ -f "$WORKSPACE_DB/$session.initialized" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

mark_workspace_initialized() {

    local session="$1"

    touch "$WORKSPACE_DB/$session.initialized"
}

########################################
# CREATE WORKSPACE
########################################

ensure_workspace() {

    local session="$1"
    local root="$2"

    ########################################
    # EXISTING SESSION
    ########################################

    if tmux has-session -t "$session" 2>/dev/null; then
        return 0
    fi

    ########################################
    # CREATE SESSION
    ########################################

    tmux new-session \
        -d \
        -s "$session" \
        -c "$root"

    ########################################
    # DEFAULT WINDOW NAME
    ########################################

    tmux rename-window \
        -t "$session:1" \
        "main"
}

