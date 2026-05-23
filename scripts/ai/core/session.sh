#!/data/data/com.termux/files/usr/bin/bash

SESSION_DB="$HOME/.ai/sessions"

mkdir -p "$SESSION_DB"

########################################
# EXISTS
########################################

session_exists() {

    local session="$1"

    tmux has-session -t "$session" 2>/dev/null
}

########################################
# SAVE
########################################

save_session() {

    local session="$1"
    local project="$2"
    local type="$3"
    local layout="$4"
    local branch="$5"

    cat > "$SESSION_DB/$session" <<EOF
SESSION_NAME="$session"
PROJECT_NAME="$project"
PROJECT_TYPE="$type"
LAYOUT="$layout"
BRANCH="$branch"
UPDATED_AT="$(date +%s)"
EOF
}

########################################
# SELECT
########################################

select_session() {

    local selected

    selected="$(
        ls "$SESSION_DB" 2>/dev/null | fzf
    )"

    echo "$selected"
}

########################################
# ATTACH
########################################

attach_workspace() {

    local session="$1"

    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "$session"
    else
        tmux attach -t "$session"
    fi
}

########################################
# RESUME
########################################

resume_last_session() {

    local latest

    latest="$(
        ls -t "$SESSION_DB" 2>/dev/null | head -n 1
    )"

    if [[ -z "$latest" ]]; then
        echo "[ai] no previous session"
        return 1
    fi

    attach_workspace "$latest"
}

