#!/data/data/com.termux/files/usr/bin/bash

spawn_subagent() {

    local session="$1"
    local agent="$2"

    tmux split-window -t "$session" -h

    tmux send-keys -t "$session" \
        "clear && echo '[subagent] $agent ready'" C-m
}

spawn_subagents() {

    local session="$1"

    shift

    local agents=("$@")

    for agent in "${agents[@]}"; do
        spawn_subagent "$session" "$agent"
    done

    tmux select-layout -t "$session" tiled
}

