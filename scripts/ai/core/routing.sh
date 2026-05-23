#!/data/data/com.termux/files/usr/bin/bash

detect_intent() {

    local prompt="${1:-}"

    prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

    ########################################
    # RESEARCH
    ########################################

    if [[ "$prompt" =~ research|investigate|analyze|rag|architecture ]]; then
        echo "research"
        return
    fi

    ########################################
    # CODING
    ########################################

    if [[ "$prompt" =~ fix|bug|error|refactor|code|implement ]]; then
        echo "coding"
        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$prompt" =~ kubernetes|docker|helm|cluster|deploy|cicd ]]; then
        echo "devops"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "lightweight"
}

