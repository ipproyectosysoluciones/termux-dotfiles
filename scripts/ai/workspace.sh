#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

########################################
# DYNAMIC BASE_DIR
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR" && pwd)"

########################################
# TEMPLATE ARGUMENT
########################################

TEMPLATE="${1:-}"

########################################
# SOURCE REQUIRED MODULES
########################################

source "$BASE_DIR/core/workspace.sh"
source "$BASE_DIR/core/layout.sh"
source "$BASE_DIR/core/runtime.sh"

########################################
# RESOLVE TEMPLATE
########################################

if [[ -z "$TEMPLATE" ]]; then
    local_env="$(detect_runtime)"
    case "$local_env" in
        mobile)
            TEMPLATE="mobile"
            ;;
        remote)
            TEMPLATE="remote"
            ;;
        node)
            TEMPLATE="node"
            ;;
        *)
            TEMPLATE="default"
            ;;
    esac
fi

########################################
# WORKSPACE SESSION
########################################

SESSION_NAME="workspace"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$HOME}"

if ! workspace_initialized "$SESSION_NAME"; then
    ensure_workspace "$SESSION_NAME" "$WORKSPACE_ROOT"
    apply_layout "$SESSION_NAME" "$TEMPLATE"
    mark_workspace_initialized "$SESSION_NAME"
fi

########################################
# ATTACH
########################################

tmux attach-session -t "$SESSION_NAME" 2>/dev/null || tmux new-session -s "$SESSION_NAME"
