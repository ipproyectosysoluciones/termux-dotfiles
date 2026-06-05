#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

if ! command -v gentle-ai > /dev/null 2>&1; then
    echo "gentle-ai is not installed."
    echo "gentle-ai is a control-plane tool for AI orchestration."
    echo "Install: see https://github.com/agentuity/gentle-ai"
    echo ""
    echo "Tip: use gemini or opencode providers for AI queries."
    exit 1
fi

SESSION="gentle"

launch_in_window "$SESSION" "gentle-ai" "gentle"
