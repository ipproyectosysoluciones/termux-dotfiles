#!/data/data/com.termux/files/usr/bin/bash

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
            echo "[ai] unknown provider: $provider"
            return 1
            ;;

    esac
}

