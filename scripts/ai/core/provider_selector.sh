#!/data/data/com.termux/files/usr/bin/bash

select_provider() {

    local project_type="$1"
    local runtime_mode="$2"
    local policy_mode="$3"
    local intent_mode="$4"

    ########################################
    # INTENT FIRST
    ########################################

    case "$intent_mode" in

        research)
            echo "gemini"
            return
            ;;

        architecture)
            echo "claude"
            return
            ;;

        coding)
            echo "claude"
            return
            ;;

        lightweight)
            echo "opencode"
            return
            ;;

    esac

    ########################################
    # POLICY FALLBACK
    ########################################

    case "$policy_mode" in

        lightweight)
            echo "opencode"
            ;;

        balanced)
            echo "claude"
            ;;

        heavy)
            echo "gemini"
            ;;

        *)
            echo "claude"
            ;;

    esac
}
