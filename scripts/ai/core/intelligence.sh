#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/core/state.sh"

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

