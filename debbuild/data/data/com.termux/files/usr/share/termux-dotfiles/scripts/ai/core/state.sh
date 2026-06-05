#!/data/data/com.termux/files/usr/bin/bash

STATE_DIR="$HOME/.ai/state"

mkdir -p "$STATE_DIR"

########################################
# CURRENT WORKSPACE
########################################

save_current_workspace() {

    local session="$1"
    local project="$2"
    local root="$3"
    local type="$4"
    local branch="$5"
    local layout="$6"

    cat > "$STATE_DIR/current_workspace" <<EOF
SESSION_NAME="$session"
PROJECT_NAME="$project"
PROJECT_ROOT="$root"
PROJECT_TYPE="$type"
GIT_BRANCH="$branch"
LAYOUT="$layout"
UPDATED_AT="$(date +%s)"
EOF
}

########################################
# LOAD
########################################

load_current_workspace() {

    local file="$STATE_DIR/current_workspace"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    source "$file"
}

########################################
# CLEAR
########################################

clear_current_workspace() {

    rm -f "$STATE_DIR/current_workspace"
}

