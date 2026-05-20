#!/data/data/com.termux/files/usr/bin/bash

select_layout() {

    local project_type="$1"

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

