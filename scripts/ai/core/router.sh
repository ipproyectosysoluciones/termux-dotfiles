#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"
source "$HOME/dotfiles/scripts/ai/providers/gentle.sh"

run_provider() {

    local provider="$1"

    shift || true

    case "$provider" in

        ########################################
        # OPENCODE
        ########################################

        opencode)
            run_opencode run "$@"
            ;;

        ########################################
        # GEMINI
        ########################################

        gemini)
            run_gemini "$@"
            ;;

        ########################################
        # CLAUDE
        ########################################

        claude)
            run_claude "$@"
            ;;

        ########################################
        # GENTLE-AI
        ########################################

        gentle)
            run_gentle "$@"
            ;;

        ########################################
        # DEFAULT
        ########################################

        *)
            echo "[ai] unknown provider: $provider"
            return 1
            ;;

    esac
}

