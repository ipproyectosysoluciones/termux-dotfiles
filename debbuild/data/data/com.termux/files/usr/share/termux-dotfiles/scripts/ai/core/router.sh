#!/data/data/com.termux/files/usr/bin/bash

# Dynamic BASE_DIR detection for portability
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$BASE_DIR/providers/claude.sh"
source "$BASE_DIR/providers/gemini.sh"
source "$BASE_DIR/providers/opencode.sh"
source "$BASE_DIR/providers/gentle.sh"
source "$BASE_DIR/providers/mistral.sh"

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
        # MISTRAL
        ########################################

        mistral)
            run_mistral "$@"
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

