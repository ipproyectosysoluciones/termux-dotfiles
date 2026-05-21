#!/data/data/com.termux/files/usr/bin/bash

detect_policy() {

    ########################################
    # OFFLINE
    ########################################

    if [[ "$NETWORK_MODE" == "offline" ]]; then
        echo "offline"
        return
    fi

    ########################################
    # MOBILE
    ########################################

    if [[ "$RUNTIME_MODE" == "mobile" ]]; then
        echo "lightweight"
        return
    fi

    ########################################
    # REMOTE
    ########################################

    if [[ "$RUNTIME_MODE" == "remote" ]]; then
        echo "remote-safe"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "standard"
}

