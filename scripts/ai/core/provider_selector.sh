#!/data/data/com.termux/files/usr/bin/bash

select_provider() {

    local project_type="${1:-generic}"
    local runtime="${2:-mobile}"
    local policy="${3:-lightweight}"
    local intent="${4:-lightweight}"

    ########################################
    # RESEARCH
    ########################################

    if [[ "$intent" == "research" ]]; then

        if provider_available gemini; then
            echo "gemini"
            return
        fi

        echo "opencode"
        return
    fi

    ########################################
    # ARCHITECTURE
    ########################################

    if [[ "$intent" == "architecture" ]]; then

        if provider_available gemini; then
            echo "gemini"
            return
        fi

        echo "opencode"
        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$intent" == "devops" ]]; then

        if provider_available opencode; then
            echo "opencode"
            return
        fi
    fi

    ########################################
    # CODING
    ########################################

    if [[ "$intent" == "coding" ]]; then

        if provider_available opencode; then
            echo "opencode"
            return
        fi
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "opencode"
}

