#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"
source "$HOME/dotfiles/scripts/ai/providers/gentle.sh"

run_provider() {

    local provider="${1:-}"
    shift

    local prompt="${*:-}"

    case "$provider" in

        ########################################
        # OPENCODE
        ########################################

        opencode)

            run_opencode \
                run \
                --prompt "$prompt"

            ;;

        ########################################
        # GEMINI
        ########################################

        gemini)

            run_gemini \
                --prompt "$prompt"

            ;;

        ########################################
        # CLAUDE
        ########################################

        claude)

            run_claude "$prompt"

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

