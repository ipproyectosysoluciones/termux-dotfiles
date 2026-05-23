#!/data/data/com.termux/files/usr/bin/bash

check_binary() {

    local name="$1"

    if command -v "$name" >/dev/null 2>&1; then
        echo "[ok] $name"
    else
        echo "[warn] $name"
    fi
}

run_doctor() {

    echo
    echo "[ai] runtime diagnostics"
    echo

    ########################################
    # AI
    ########################################

    check_binary claude
    check_binary gemini
    check_binary opencode

    ########################################
    # DEV
    ########################################

    check_binary node
    check_binary pnpm

    ########################################
    # CONTAINERS
    ########################################

    check_binary docker
    check_binary kubectl
    check_binary helm

    ########################################
    # MEMORY
    ########################################

    check_binary engram

    echo
}

