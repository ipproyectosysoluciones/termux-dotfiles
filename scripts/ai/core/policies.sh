#!/data/data/com.termux/files/usr/bin/bash

detect_policy() {

    local runtime

    runtime="$(detect_runtime)"

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

   if [[ "$runtime" == "mobile" ]]; then
        echo "lightweight"
        return
    fi

    ########################################
    # REMOTE
    ########################################

   if [[ "$runtime" == "remote" ]]; then
        echo "balanced"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "standard"
}

