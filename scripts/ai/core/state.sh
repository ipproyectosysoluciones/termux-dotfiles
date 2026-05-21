#!/data/data/com.termux/files/usr/bin/bash

AI_STATE_DIR="$HOME/.local/share/ai"

STATE_FILE="$AI_STATE_DIR/state.env"

mkdir -p "$AI_STATE_DIR"

save_state() {

    mkdir -p "$AI_STATE_DIR"

    cat > "$STATE_FILE" <<EOF
LAST_SESSION="${SESSION_NAME:-unknown}"
LAST_PROJECT="${PROJECT_NAME:-unknown}"
LAST_PROVIDER="${PROVIDER:-unknown}"
LAST_PATH="${PROJECT_ROOT:-$HOME}"
LAST_TYPE="${PROJECT_TYPE:-generic}"
LAST_ACCESS="$(date +%s)"
EOF
}

load_state() {

    [[ -f "$STATE_FILE" ]] || return 1

    source "$STATE_FILE"
}
