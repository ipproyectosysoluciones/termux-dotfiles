#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

BASE_DIR="$HOME/dotfiles/scripts/ai"

########################################
# CORE
########################################

source "$BASE_DIR/core/registry.sh"
source "$BASE_DIR/core/routing.sh"
source "$BASE_DIR/core/provider_selector.sh"

source "$BASE_DIR/core/intelligence.sh"
source "$BASE_DIR/core/metadata.sh"
source "$BASE_DIR/core/state.sh"
source "$BASE_DIR/core/hooks.sh"
source "$BASE_DIR/core/memory.sh"
source "$BASE_DIR/core/hydration.sh"
source "$BASE_DIR/core/runtime.sh"
source "$BASE_DIR/core/skill_registry.sh"
source "$BASE_DIR/core/skill_detector.sh"
source "$BASE_DIR/core/capability_router.sh"
source "$BASE_DIR/core/agent_registry.sh"
source "$BASE_DIR/core/agent_router.sh"
source "$BASE_DIR/core/agent_context.sh"
source "$BASE_DIR/core/paths.sh"
source "$BASE_DIR/core/sync.sh"
source "$BASE_DIR/core/policies.sh"
source "$BASE_DIR/core/project.sh"
source "$BASE_DIR/core/session.sh"
source "$BASE_DIR/core/workspace.sh"
source "$BASE_DIR/core/layout.sh"
source "$BASE_DIR/core/doctor.sh"

source "$BASE_DIR/core/router.sh"

########################################
# PROJECT
########################################

PROJECT_ROOT="$(detect_project)"
PROJECT_NAME="$(project_name "$PROJECT_ROOT")"
PROJECT_TYPE="$(project_type "$PROJECT_ROOT")"
GIT_BRANCH="$(git_branch "$PROJECT_ROOT")"

########################################
# RUNTIME
########################################

RUNTIME_MODE="$(detect_runtime)"
NETWORK_MODE="$(detect_network)"
TMUX_MODE="$(detect_tmux_mode)"
POLICY_MODE="$(detect_policy)"

########################################
# PROMPT
########################################

PROMPT="${*:-}"

HYDRATED_PROMPT=""

SKILL_MODE="$(detect_skill "$PROMPT")"

INTENT_MODE="$(
    route_capability "$SKILL_MODE"
)"

AGENT_MODE="$(
    resolve_agent "$SKILL_MODE"
)"

########################################
# HEADER
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
echo "[ai] intent  : $INTENT_MODE"
echo "[ai] skill   : $SKILL_MODE"
echo "[ai] agent   : $AGENT_MODE"
echo

########################################
# DOCTOR
########################################

if [[ "${1:-}" == "doctor" ]]; then
    run_doctor
    exit 0
fi

########################################
# RESUME
########################################

if [[ "${1:-}" == "resume" ]]; then
    resume_last_session
    exit 0
fi

########################################
# PROVIDER
########################################

PROVIDER="$(
    route_agent_provider "$AGENT_MODE"
)"

echo "[ai] provider : $PROVIDER"
echo

########################################
# MEMORY CONTEXT
########################################

MEMORY_CONTEXT="$(
    memory_project_context "$PROJECT_NAME"
)"

export MEMORY_CONTEXT

########################################
# EXECUTION
########################################

memory_save "user" "$PROMPT"

HYDRATED_PROMPT="$(
    build_context "$PROMPT"
)"

mirror_project \
    "$PROJECT_ROOT" \
    "$PROJECT_NAME"

run_provider "$PROVIDER" "$HYDRATED_PROMPT"

