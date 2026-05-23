#!/data/data/com.termux/files/usr/bin/bash

AI_STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ai"

SESSION_DIR="$AI_STATE_DIR/sessions"

mkdir -p "$SESSION_DIR"

session_file() {
    echo "$SESSION_DIR/$1.env"
}

save_session() {

    local session="$1"
    local project="$2"
    local type="$3"
    local layout="$4"
    local branch="$5"

    cat > "$(session_file "$session")" <<EOF
SESSION=$session
PROJECT=$project
TYPE=$type
LAYOUT=$layout
BRANCH=$branch
LAST_USED=$(date +%s)
EOF
}

load_session() {

    local session="$1"

    local file
    file="$(session_file "$session")"

    if [[ -f "$file" ]]; then
        source "$file"
    fi
}

list_sessions() {
    ls "$SESSION_DIR" 2>/dev/null \
        | sed 's/\.env$//'
}

