#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"

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
            run_opencode run "$*"
            ;;

        *)
            echo "[ai] unknown provider"
            return 1
            ;;

    esac
}

