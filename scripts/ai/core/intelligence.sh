#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/state.sh"

resume_last_session() {

    load_state || {
        echo "[ai] no saved session"
        return 1
    }

    echo "[ai] restoring : $LAST_SESSION"

    ########################################
    # EXISTING SESSION
    ########################################

    if tmux has-session -t "$LAST_SESSION" 2>/dev/null; then

        if [[ -n "${TMUX:-}" ]]; then
            tmux switch-client -t "$LAST_SESSION"
        else
            tmux attach-session -t "$LAST_SESSION"
        fi

        return
    fi

    ########################################
    # RECOVER SESSION
    ########################################

    echo "[ai] recovering workspace"

    tmux new-session \
        -ds "$LAST_SESSION" \
        -c "$LAST_PATH"

    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "$LAST_SESSION"
    else
        tmux attach-session -t "$LAST_SESSION"
    fi
}

