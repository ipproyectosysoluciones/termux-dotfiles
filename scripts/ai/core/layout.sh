#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/core/runtime.sh"

select_layout() {

    local project_type="$1"

    local env
    env="$(environment_type)"

    if [[ "$env" == "mobile" ]]; then
        echo "mobile"
        return
    fi

    if [[ "$env" == "remote" ]]; then
        echo "remote"
        return
    fi

    case "$project_type" in
        node)
            echo "node"
            ;;
        docker)
            echo "infra"
            ;;
        *)
            echo "default"
            ;;
    esac
}

apply_layout() {

    local session="$1"
    local layout="$2"

    local template="$HOME/dotfiles/scripts/ai/templates/${layout}.sh"

    if [[ -f "$template" ]]; then
        source "$template"
        build_layout "$session"
    fi
}

