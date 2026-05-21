#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/core/context.sh"
source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"

select_provider() {

    local project_type="$1"

    ########################################
    # OFFLINE
    ########################################

    if is_offline; then
        echo "opencode"
        return
    fi

    ########################################
    # MOBILE SSH
    ########################################

    if is_remote_session && is_mobile_termux; then
        echo "opencode"
        return
    fi

    ########################################
    # BATTERY SAVING
    ########################################

    if has_battery_constraints; then
        echo "opencode"
        return
    fi

    ########################################
    # PROJECT TYPES
    ########################################

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

