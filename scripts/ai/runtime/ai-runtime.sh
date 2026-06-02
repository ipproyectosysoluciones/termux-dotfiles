    #!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

export PATH="/data/data/com.termux/files/usr/bin:$PATH"

if command -v rg >/dev/null 2>&1; then
    export RIPGREP_BINARY="$(command -v rg)"
fi

########################################
# BASE
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$BASE_DIR/runtime/runtime.env"

export PATH="$PREFIX/bin:$PATH"
export GEMINI_DISABLE_MCP="1"
export GEMINI_DISABLE_TELEMETRY="1"
export GEMINI_DISABLE_AUTOUPDATE="1"

ulimit -n 1024

########################################
# CORE
########################################

source "$BASE_DIR/core/router.sh"
source "$BASE_DIR/core/memory.sh"
source "$BASE_DIR/core/sync.sh"

########################################
# INPUT
########################################

PROVIDER="${1:-}"

shift || true

PROMPT=""

if [[ -n "${AI_PROMPT_FILE:-}" ]] && [[ -f "$AI_PROMPT_FILE" ]]; then
    PROMPT="$(cat "$AI_PROMPT_FILE")"
else
    PROMPT="${*:-}"
fi

export AI_PROJECT="${AI_PROJECT:-default}"
export AI_AGENT="${AI_AGENT:-generic-agent}"
export AI_SKILL="${AI_SKILL:-generic-skill}"
export AI_WORKSPACE="${AI_WORKSPACE:-$PWD}"
export PATH="/data/data/com.termux/files/usr/bin:$PATH"

ulimit -n 1024 || true

########################################
# PROJECT CONTEXT
########################################

PROJECT="${AI_PROJECT:-default}"

WORKSPACE="$HOME/.ai-sync/$PROJECT"

mkdir -p "$WORKSPACE"

cd "$WORKSPACE" || exit 1

########################################
# DEBUG
########################################

echo "[runtime] provider  : $PROVIDER"
echo "[runtime] project   : $PROJECT"
echo "[runtime] workspace : $WORKSPACE"
echo

########################################
# EXECUTION
########################################

echo "[runtime] AI_PROJECT=${AI_PROJECT:-undefined}"
echo "[runtime] AI_AGENT=${AI_AGENT:-undefined}"
echo "[runtime] AI_SKILL=${AI_SKILL:-undefined}"

run_provider "$PROVIDER" "$PROMPT"

