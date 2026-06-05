#!/data/data/com.termux/files/usr/bin/bash

detect_runtime() {

    ########################################
    # MOBILE
    ########################################

    if [[ -d "/data/data/com.termux" ]]; then
        echo "mobile"
        return
    fi

    ########################################
    # REMOTE
    ########################################

    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        echo "remote"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "local"
}

detect_tmux_mode() {

    if [[ -n "${TMUX:-}" ]]; then
        echo "nested"
        return
    fi

    echo "standalone"
}

detect_network() {

    if ping -c 1 1.1.1.1 >/dev/null 2>&1; then
        echo "online"
        return
    fi

    echo "offline"
}

