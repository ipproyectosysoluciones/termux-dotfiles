#!/data/data/com.termux/files/usr/bin/bash

resolve_subagents() {

    local prompt="${1:-}"

    prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

    ########################################
    # FULL PLATFORM
    ########################################

    if [[ "$prompt" =~ production|platform|fullstack ]]; then

        cat <<EOF
mern-agent
kubernetes-agent
security-agent
observability-agent
EOF

        return
    fi

    ########################################
    # DEVOPS
    ########################################

    if [[ "$prompt" =~ kubernetes|cluster|helm ]]; then

        cat <<EOF
kubernetes-agent
security-agent
EOF

        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "general-agent"
}

