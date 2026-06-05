#!/data/data/com.termux/files/usr/bin/bash

route_agent_provider() {

    local agent="${1:-general-agent}"

    ########################################
    # RESEARCH
    ########################################

    if [[ "$agent" == "rag-agent" ]]; then
        echo "gemini"
        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$agent" == "kubernetes-agent" ]]; then
        echo "opencode"
        return
    fi

    ########################################
    # MERN
    ########################################

    if [[ "$agent" == "mern-agent" ]]; then
        echo "claude"
        return
    fi

    ########################################
    # TERMINAL
    ########################################

    if [[ "$agent" == "terminal-agent" ]]; then
        echo "opencode"
        return
    fi

    ########################################
    # NVIM
    ########################################

    if [[ "$agent" == "editor-agent" ]]; then
        echo "claude"
        return
    fi

    ########################################
    # MISTRAL
    ########################################

    if [[ "$agent" == "mistral" ]]; then
        echo "mistral"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "opencode"
}

