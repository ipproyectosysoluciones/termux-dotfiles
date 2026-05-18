#!/data/data/com.termux/files/usr/bin/bash

set -e

SESSION="ai-workspace"

if ! tmux has-session -t $SESSION 2>/dev/null; then

  tmux new-session -d -s $SESSION -n editor

  tmux send-keys -t $SESSION:editor \
    "cd ~/dotfiles && nvim" C-m

  tmux split-window -h -t $SESSION:editor

  tmux send-keys -t $SESSION \
    "bash ~/dotfiles/scripts/ai/opencode.sh" C-m

  tmux split-window -v -t $SESSION

  tmux send-keys -t $SESSION \
    "bash ~/dotfiles/scripts/ai/gentle.sh" C-m

  tmux new-window -t $SESSION -n memory

  tmux send-keys -t $SESSION:memory \
    "bash ~/dotfiles/scripts/ai/engram.sh" C-m

  tmux select-layout tiled
fi

if [ -n "$TMUX" ]; then
  tmux switch-client -t $SESSION
else
  tmux attach-session -t $SESSION
fi

