#########################################
# AUTO TMUX
#########################################

cd "$PROJECTS_DIR"

if command -v tmux >/dev/null 2>&1; then
    if [[ -z "$TMUX" && -o interactive ]]; then
        tmux attach -t main || tmux new -s main
    fi
fi
