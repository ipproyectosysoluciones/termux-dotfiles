#!/data/data/com.termux/files/usr/bin/bash

run_opencode() {

    if command -v opencode >/dev/null 2>&1; then
        opencode "$@"
    else
        echo "[ai] opencode unavailable"
        return 1
    fi
}

