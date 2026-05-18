#!/data/data/com.termux/files/usr/bin/bash

SESSION="opencode"

if ! tmux has-session -t $SESSION 2>/dev/null; then
    tmux new-session -d -s $SESSION

    tmux send-keys -t $SESSION "cd ~/Projects" C-m
    tmux send-keys -t $SESSION "echo 'OpenCode runtime'" C-m
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t $SESSION
else
    tmux attach -t $SESSION
fi

