#!/data/data/com.termux/files/usr/bin/bash

orchestrate_agents() {

    local session="$1"
    local prompt="$2"

    mapfile -t SUBAGENTS < <(
        resolve_subagents "$prompt"
    )

    ########################################
    # DEBUG
    ########################################

    echo
    echo "[ai] orchestration"
    echo

    for agent in "${SUBAGENTS[@]}"; do
        echo "  -> $agent"
    done

    ########################################
    # SPAWN
    ########################################

    spawn_subagents "$session" "${SUBAGENTS[@]}"
}

