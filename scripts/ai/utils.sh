#!/data/data/com.termux/files/usr/bin/bash

session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

attach_or_switch() {
    local session="$1"

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session"
    else
        tmux attach -t "$session"
    fi
}

create_session() {
    local session="$1"
    local command="$2"

    if ! session_exists "$session"; then
        tmux new-session -d -s "$session"

        if [ -n "$command" ]; then
            tmux send-keys -t "$session" "$command" C-m
        fi
    fi
}

# Open a command in a new tmux window (if inside tmux) or new session (if standalone)
# Usage: launch_in_window <session-name> <command> [window-name]
launch_in_window() {
    local session="$1"
    local command="$2"
    local window_name="${3:-$1}"

    if [ -n "$TMUX" ]; then
        # Inside tmux: open a new window in the current session
        # The menu stays visible, user can switch back with Ctrl+B+arrows
        tmux new-window -n "$window_name" "$command"
    else
        # Outside tmux: create a new session and attach
        if ! session_exists "$session"; then
            tmux new-session -d -s "$session"
            if [ -n "$command" ]; then
                tmux send-keys -t "$session" "$command" C-m
            fi
        fi
        tmux attach -t "$session"
    fi
}
