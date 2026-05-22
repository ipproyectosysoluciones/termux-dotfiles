#!/data/data/com.termux/files/usr/bin/bash

detect_intent() {

    local prompt="$*"

    ########################################
    # QUICK
    ########################################

    if echo "$prompt" | grep -Eqi \
        "quick|fast|simple|fix|error|debug"; then

        echo "lightweight"
        return
    fi

    ########################################
    # ARCHITECTURE
    ########################################

    if echo "$prompt" | grep -Eqi \
        "architecture|kubernetes|infra|helm|docker|cluster"; then

        echo "architecture"
        return
    fi

    ########################################
    # RESEARCH
    ########################################

    if echo "$prompt" | grep -Eqi \
        "research|analyze|compare|investigate|rag"; then

        echo "research"
        return
    fi

    ########################################
    # CODING
    ########################################

    if echo "$prompt" | grep -Eqi \
        "code|refactor|typescript|node|react|bug"; then

        echo "coding"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "general"
}

