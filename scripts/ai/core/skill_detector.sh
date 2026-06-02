#!/data/data/com.termux/files/usr/bin/bash

detect_skill() {

    local prompt="${1:-}"

    prompt="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

    ########################################
    # RAG
    ########################################

    if [[ "$prompt" =~ rag|retrieval|embedding|vector|graphrag ]]; then
        echo "rag-research"
        return
    fi

    ########################################
    # KUBERNETES
    ########################################

    if [[ "$prompt" =~ kubernetes|helm|k8s|cluster ]]; then
        echo "k8s-devops"
        return
    fi

    ########################################
    # MERN
    ########################################

    if [[ "$prompt" =~ react|node|express|mongo|mern ]]; then
        echo "mern-engineer"
        return
    fi

    ########################################
    # TMUX
    ########################################

    if [[ "$prompt" =~ tmux|session|pane|workspace ]]; then
        echo "terminal-automation"
        return
    fi

    ########################################
    # NVIM
    ########################################

    if [[ "$prompt" =~ nvim|neovim|treesitter|lsp|editor ]]; then
        echo "editor-engineering"
        return
    fi

    ########################################
    # DEFAULT
    ########################################

    echo "general"
}

