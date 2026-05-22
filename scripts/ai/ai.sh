#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

########################################
# BASE
########################################

BASE_DIR="$HOME/dotfiles/scripts/ai"

########################################
# CORE
########################################

source "$BASE_DIR/core/intelligence.sh"
source "$BASE_DIR/core/metadata.sh"
source "$BASE_DIR/core/state.sh"
source "$BASE_DIR/core/hooks.sh"
source "$BASE_DIR/core/runtime.sh"
source "$BASE_DIR/core/policies.sh"
source "$BASE_DIR/core/project.sh"
source "$BASE_DIR/core/session.sh"
source "$BASE_DIR/core/workspace.sh"
source "$BASE_DIR/core/layout.sh"
source "$BASE_DIR/core/doctor.sh"
source "$BASE_DIR/core/provider_selector.sh"
source "$BASE_DIR/core/routing.sh"
source "$BASE_DIR/core/registry.sh"
source "$BASE_DIR/core/selector.sh"
source "$BASE_DIR/core/router.sh"

########################################
# PROJECT
########################################

PROJECT_ROOT="$(detect_project)"
PROJECT_NAME="$(project_name "$PROJECT_ROOT")"
PROJECT_TYPE="$(project_type "$PROJECT_ROOT")"
GIT_BRANCH="$(git_branch "$PROJECT_ROOT")"

SESSION_NAME="$PROJECT_NAME"

########################################
# RUNTIME
########################################

RUNTIME_MODE="$(detect_runtime)"
NETWORK_MODE="$(detect_network)"
TMUX_MODE="$(detect_tmux_mode)"
POLICY_MODE="$(detect_policy)"

########################################
# PROMPT / INTENT
########################################

PROMPT="${*:-}"

INTENT_MODE="$(detect_intent "$PROMPT")"

########################################
# DISPLAY
########################################

echo
echo "[ai] project : $PROJECT_NAME"
echo "[ai] type    : $PROJECT_TYPE"
echo "[ai] branch  : $GIT_BRANCH"
echo "[ai] root    : $PROJECT_ROOT"
echo "[ai] runtime : $RUNTIME_MODE"
echo "[ai] network : $NETWORK_MODE"
echo "[ai] tmux    : $TMUX_MODE"
echo "[ai] policy  : $POLICY_MODE"
# echo # "[ai] intent  : $INTENT_MODE"
printf '[ai] intent  : <%s>\n' "$INTENT_MODE"
printf '[debug] selector input : <%s>\n' "$INTENT_MODE"
echo

########################################
# METADATA
########################################

LAYOUT="existing"

ensure_workspace_metadata

load_workspace_metadata || true

########################################
# COMMANDS
########################################

if [[ "${1:-}" == "doctor" ]]; then
    run_doctor
    exit 0
fi

if [[ "${1:-}" == "resume" ]]; then
    resume_last_session
    exit 0
fi

if [[ "${1:-}" == "switch" ]]; then

    SESSION="$(select_session)"

    if [[ -n "$SESSION" ]]; then
        attach_workspace "$SESSION"
    fi

    exit 0
fi

########################################
# ASK MODE
########################################

if [[ "${1:-}" == "ask" ]]; then

    shift

    PROVIDER="$(select_provider \
        "$PROJECT_TYPE" \
        "$RUNTIME_MODE" \
        "$POLICY_MODE" \
        "$INTENT_MODE")"

    save_state

    echo "[ai] provider : $PROVIDER"
    echo

    run_provider "$PROVIDER" "$@"

    exit 0
fi

########################################
# DIRECT PROMPT MODE
########################################

if [[ $# -gt 0 ]]; then

    PROVIDER="$(select_provider \
        "$PROJECT_TYPE" \
        "$RUNTIME_MODE" \
        "$POLICY_MODE" \
        "$INTENT_MODE")"

    save_state

    echo "[ai] provider : $PROVIDER"
    echo

    run_provider "$PROVIDER" "$@"

    exit 0
fi

########################################
# WORKSPACE
########################################

ensure_workspace \
    "$SESSION_NAME" \
    "$PROJECT_ROOT"

########################################
# BOOTSTRAP
########################################

if [[ "$(workspace_initialized "$SESSION_NAME")" != "true" ]]; then

    LAYOUT="$(select_layout "$PROJECT_TYPE")"

    echo "[ai] layout  : $LAYOUT"
    echo

    apply_layout \
        "$SESSION_NAME" \
        "$LAYOUT"

    run_startup_hooks "$SESSION_NAME"

    mark_workspace_initialized "$SESSION_NAME"
fi

########################################
# SESSION SAVE
########################################

save_session \
    "$SESSION_NAME" \
    "$PROJECT_NAME" \
    "$PROJECT_TYPE" \
    "$LAYOUT" \
    "$GIT_BRANCH"

########################################
# ATTACH
########################################

attach_workspace "$SESSION_NAME"

