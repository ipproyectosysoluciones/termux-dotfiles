#!/data/data/com.termux/files/usr/bin/bash

SESSION="nvim"

if ! tmux has-session -t $SESSION 2>/dev/null; then
    tmux new-session -d -s $SESSION "cd ~/Projects && nvim"
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t $SESSION
else
    tmux attach -t $SESSION
fi

