#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"

select_provider() {

    local project_type="$1"

    case "$project_type" in

        kubernetes|infra)
            echo "gemini"
            ;;

        node|react|frontend)
            echo "claude"
            ;;

        generic)
            echo "opencode"
            ;;

        *)
            echo "claude"
            ;;

    esac
}

run_provider() {

    local provider="$1"

    shift

    case "$provider" in

        claude)
            run_claude "$@"
            ;;

        gemini)
            run_gemini "$@"
            ;;

        opencode)
            run_opencode "$@"
            ;;

    esac
}

