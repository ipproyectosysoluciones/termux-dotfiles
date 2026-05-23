#!/data/data/com.termux/files/usr/bin/bash

is_ssh_session() {
    [[ -n "${SSH_CONNECTION:-}" ]]
}

is_tmux_session() {
    [[ -n "${TMUX:-}" ]]
}

is_remote_session() {

    if is_ssh_session; then
        return 0
    fi

    return 1
}

is_mobile_termux() {

    [[ -d "/data/data/com.termux" ]]
}

has_battery_constraints() {

    if command -v termux-battery-status >/dev/null 2>&1; then

        local percentage

        percentage="$(
            termux-battery-status \
            | jq -r '.percentage'
        )"

        [[ "$percentage" -lt 20 ]]

        return
    fi

    return 1
}

is_offline() {

    ping -c 1 1.1.1.1 >/dev/null 2>&1

    [[ "$?" -ne 0 ]]
}

