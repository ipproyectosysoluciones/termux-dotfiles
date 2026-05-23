#!/data/data/com.termux/files/usr/bin/bash

########################################
# PROVIDER REGISTRY
########################################

AI_PROVIDERS=(
    "opencode"
    "claude"
    "gemini"
)

########################################
# CAPABILITIES
########################################

provider_supports() {

    local provider="$1"
    local capability="$2"

    case "$provider:$capability" in

        ########################################
        # OPENCODE
        ########################################

        opencode:coding)
            return 0
            ;;

        opencode:research)
            return 0
            ;;

        opencode:lightweight)
            return 0
            ;;

        opencode:mobile)
            return 0
            ;;

        ########################################
        # CLAUDE
        ########################################

        claude:architecture)
            return 0
            ;;

        claude:devops)
            return 0
            ;;

        claude:long_context)
            return 0
            ;;

        ########################################
        # GEMINI
        ########################################

        gemini:research)
            return 0
            ;;

        gemini:web)
            return 0
            ;;

        gemini:multimodal)
            return 0
            ;;

    esac

    return 1
}

########################################
# HEALTH
########################################

provider_available() {

    local provider="$1"

    command -v "$provider" >/dev/null 2>&1
}

