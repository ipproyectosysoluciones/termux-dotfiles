#!/data/data/com.termux/files/usr/bin/bash

detect_intent() {

    local prompt="${1:-}"

    prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

    ########################################
    # RESEARCH
    ########################################

    if [[ "$prompt" =~ research|investigate|analyze|rag ]]; then
        echo "research"
        return
    fi

    ########################################
    # ARCHITECTURE
    ########################################

    if [[ "$prompt" =~ architecture|design|system|distributed|event\ sourcing ]]; then
        echo "architecture"
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
    # CODING
    ########################################

    if [[ "$prompt" =~ fix|bug|error|refactor|code|implement|auth ]]; then
        echo "coding"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "lightweight"
}

