#!/data/data/com.termux/files/usr/bin/bash

SESSION=$(tmux ls 2>/dev/null | cut -d: -f1 | gum choose)

if [ -n "$SESSION" ]; then
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
    else
        tmux attach -t "$SESSION"
    fi
fi
