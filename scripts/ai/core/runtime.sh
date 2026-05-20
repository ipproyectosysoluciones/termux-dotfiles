#!/data/data/com.termux/files/usr/bin/bash

is_ssh() {
    [[ -n "${SSH_CONNECTION:-}" ]]
}

is_termux() {
    [[ -d "/data/data/com.termux" ]]
}

terminal_width() {
    tput cols 2>/dev/null || echo 80
}

environment_type() {

    local width
    width="$(terminal_width)"

    if is_ssh; then
        echo "remote"
        return
    fi

    if is_termux && [[ "$width" -lt 140 ]]; then
        echo "mobile"
        return
    fi

    echo "desktop"
}

