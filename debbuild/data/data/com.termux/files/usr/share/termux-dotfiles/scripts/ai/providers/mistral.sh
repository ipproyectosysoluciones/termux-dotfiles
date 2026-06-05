#!/data/data/com.termux/files/usr/bin/bash
# Mistral AI Provider
# Uses MISTRAL_API_KEY from .env

set -e

# Source environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if [[ -f "$PROJECT_ROOT/.env" ]]; then
    source "$PROJECT_ROOT/.env"
fi

run_mistral() {
    local prompt="$1"

    if [[ -z "$MISTRAL_API_KEY" ]]; then
        echo "ERROR: MISTRAL_API_KEY not set"
        return 1
    fi

    # Call Mistral API
    curl -s https://api.mistral.ai/v1/chat/completions \
        -H "Authorization: Bearer $MISTRAL_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$(cat <<EOF
{
    "model": "mistral-medium",
    "messages": [{"role": "user", "content": "$prompt"}]
}
EOF
    )" || {
        echo "ERROR: Mistral API call failed"
        return 2
    }
}

status_mistral() {
    if [[ -n "$MISTRAL_API_KEY" ]]; then
        echo "Mistral AI: configured"
        return 0
    else
        echo "Mistral AI: not configured (set MISTRAL_API_KEY in .env)"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-status}" in
        run)
            shift
            run_mistral "$@"
            ;;
        status)
            status_mistral
            ;;
        *)
            echo "Usage: $0 {run|status}"
            exit 1
            ;;
    esac
fi