#!/data/data/com.termux/files/usr/bin/bash

run_opencode() {

    local prompt="${*:-}"

    if ! command -v opencode >/dev/null 2>&1; then

        echo "[ai] opencode unavailable"

        return 1

    fi

    ########################################
    # EXECUTION
    ########################################

    opencode run "$prompt"
}

