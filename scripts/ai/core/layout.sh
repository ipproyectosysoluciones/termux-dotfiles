#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/core/runtime.sh"

select_layout() {

    local project_type="$1"

    local env

    env="$(detect_runtime)"

    ########################################
    # MOBILE
    ########################################

    if [[ "$env" == "mobile" ]]; then
        echo "mobile"
        return
    fi

    ########################################
    # REMOTE
    ########################################

    if [[ "$env" == "remote" ]]; then
        echo "remote"
        return
    fi

    ########################################
    # PROJECT TYPES
    ########################################

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

    local template

    template="$BASE_DIR/templates/${layout}.sh"

    ########################################
    # TMUX STABILIZATION
    ########################################

    sleep 0.2

    ########################################
    # APPLY TEMPLATE
    ########################################

    if [[ -f "$template" ]]; then
        source "$template"
        build_layout "$session"
    fi
}

