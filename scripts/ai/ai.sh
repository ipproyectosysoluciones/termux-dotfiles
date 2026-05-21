#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

BASE_DIR="$HOME/dotfiles/scripts/ai"

source "$BASE_DIR/core/project.sh"
source "$BASE_DIR/core/session.sh"
source "$BASE_DIR/core/workspace.sh"
source "$BASE_DIR/core/layout.sh"
source "$BASE_DIR/core/registry.sh"
source "$BASE_DIR/core/selector.sh"
source "$BASE_DIR/core/router.sh"

PROJECT_ROOT="$(detect_project)"

PROJECT_NAME="$(project_name "$PROJECT_ROOT")"

PROJECT_TYPE="$(project_type "$PROJECT_ROOT")"

GIT_BRANCH="$(git_branch "$PROJECT_ROOT")"

SESSION_NAME="$PROJECT_NAME"

echo
echo "[ai] project : $PROJECT_NAME"
echo "[ai] type    : $PROJECT_TYPE"
echo "[ai] branch  : $GIT_BRANCH"
echo "[ai] root    : $PROJECT_ROOT"
echo

NEW_SESSION="false"
LAYOUT="existing"

if [[ "${1:-}" == "ask" ]]; then

    shift

    PROVIDER="$(select_provider "$PROJECT_TYPE")"

    echo "[ai] provider : $PROVIDER"
    echo

    run_provider "$PROVIDER" "$@"

    exit 0
fi

if [[ "${1:-}" == "switch" ]]; then

    SESSION="$(select_session)"

    if [[ -n "$SESSION" ]]; then
        attach_workspace "$SESSION"
    fi

    exit 0
fi

if ! session_exists "$SESSION_NAME"; then
    NEW_SESSION="true"
fi

ensure_workspace \
    "$SESSION_NAME" \
    "$PROJECT_ROOT"

if [[ "$NEW_SESSION" == "true" ]]; then

    LAYOUT="$(select_layout "$PROJECT_TYPE")"

    echo "[ai] layout  : $LAYOUT"
    echo

    apply_layout \
        "$SESSION_NAME" \
        "$LAYOUT"
fi

save_session \
    "$SESSION_NAME" \
    "$PROJECT_NAME" \
    "$PROJECT_TYPE" \
    "$LAYOUT" \
    "$GIT_BRANCH"

attach_workspace "$SESSION_NAME"

