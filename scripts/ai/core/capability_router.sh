#!/data/data/com.termux/files/usr/bin/bash

route_capability() {

    local skill="${1:-general}"

    ########################################
    # RAG
    ########################################

    if [[ "$skill" == "rag-research" ]]; then
        echo "research"
        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$skill" == "k8s-devops" ]]; then
        echo "devops"
        return
    fi

    ########################################
    # ENGINEERING
    ########################################

    if [[ "$skill" == "mern-engineer" ]]; then
        echo "coding"
        return
    fi

    ########################################
    # TERMINAL
    ########################################

    if [[ "$skill" == "terminal-automation" ]]; then
        echo "coding"
        return
    fi

    ########################################
    # NVIM
    ########################################

    if [[ "$skill" == "editor-engineering" ]]; then
        echo "coding"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "lightweight"
}

