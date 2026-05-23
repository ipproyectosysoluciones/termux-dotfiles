#!/data/data/com.termux/files/usr/bin/bash

select_provider() {

    local project_type="${1:-generic}"
    local runtime="${2:-mobile}"
    local policy="${3:-lightweight}"
    local intent="${4:-lightweight}"

    echo "[debug] selector input : <$intent>" >&2

    ########################################
    # RESEARCH
    ########################################

    if [[ "$intent" == "research" ]]; then
        echo "opencode"
        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$intent" == "devops" ]]; then
        echo "claude"
        return
    fi

    ########################################
    # CODING
    ########################################

    if [[ "$intent" == "coding" ]]; then

        if [[ "$runtime" == "mobile" ]]; then
            echo "opencode"
            return
        fi

        echo "claude"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "opencode"
}

