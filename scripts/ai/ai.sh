#!/data/data/com.termux/files/usr/bin/bash

set -eo pipefail

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
source "$BASE_DIR/core/subagent_registry.sh"
source "$BASE_DIR/core/subagent_runtime.sh"
source "$BASE_DIR/core/orchestration.sh"
source "$BASE_DIR/core/runtime_session.sh"
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

ORCHESTRATION_MODE="false"

if [[ "$PROMPT" =~ production|platform|distributed|fullstack ]]; then
    ORCHESTRATION_MODE="true"
fi

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

echo "[debug] after memory_save"
sleep 2

HYDRATED_PROMPT="$(
    build_context "$PROMPT"
)"

echo "[debug] after build_context"
sleep 2

export AI_PROJECT="$PROJECT_NAME"
export AI_AGENT="$AGENT_MODE"
export AI_SKILL="$SKILL_MODE"
export AI_WORKSPACE="$HOME/.ai-sync/$PROJECT_NAME"

mirror_project \
    "$PROJECT_ROOT" \
    "$PROJECT_NAME"

echo "[debug] after mirror_project"
sleep 2

########################################
# RUNTIME SESSION
########################################

SESSION_NAME="$(
    runtime_session_name "$PROJECT_NAME"
)"

ensure_runtime_session "$SESSION_NAME"

echo "[debug] reached tmux execution"
sleep 2

RUNTIME_ENV_FILE="$BASE_DIR/runtime/runtime.env"

cat > "$RUNTIME_ENV_FILE" <<EOF
export AI_PROJECT="$PROJECT_NAME"
export AI_PROJECT_ROOT="$PROJECT_ROOT"
export AI_PROVIDER="$PROVIDER"
export AI_AGENT="$AGENT_MODE"
export AI_SKILL="$SKILL_MODE"
EOF

########################################
# TMUX EXECUTION
########################################

if [[ "$ORCHESTRATION_MODE" == "true" ]]; then

    ########################################
    # NESTED TMUX
    ########################################

    if [[ "$TMUX_MODE" == "nested" ]]; then

        echo "[debug] entering nested orchestration"
        echo "[debug] TMUX_MODE=$TMUX_MODE"
        sleep 2

	LOG_FILE="$HOME/.ai-logs/${AGENT_MODE}.log"

	mkdir -p "$HOME/.ai-logs"

	tmux split-window -v \
    		"bash -lc '
        		source \"$BASE_DIR/runtime/runtime.env\"

        		$HOME/dotfiles/scripts/ai/runtime/ai-runtime.sh \
            			\"$PROVIDER\" \
            			\"$HYDRATED_PROMPT\"
    		'"

    ########################################
    # STANDALONE TMUX
    ########################################

    else

        SESSION_NAME="$PROJECT_NAME"

        tmux new-session \
            -d \
            -s "$SESSION_NAME" \
            "$HOME/dotfiles/scripts/ai/runtime/ai-runtime.sh \"$PROVIDER\" \"$HYDRATED_PROMPT\""

        attach_runtime_session "$SESSION_NAME"

    fi

    exit 0

fi

########################################
# SINGLE AGENT EXECUTION
########################################

if [[ "$TMUX_MODE" == "nested" ]]; then

    echo "[debug] entering nested orchestration"
    echo "[debug] TMUX_MODE=$TMUX_MODE"
    sleep 2

    ########################################
    # PROMPT FILE
    ########################################

    PROMPT_DIR="$HOME/.cache/ai-prompts"
    mkdir -p "$PROMPT_DIR"
    PROMPT_FILE="$PROMPT_DIR/ai_prompt_${SESSION_NAME}.txt"
    printf "%s" "$HYDRATED_PROMPT" > "$PROMPT_FILE"
    export AI_PROMPT_FILE="$PROMPT_FILE"

    tmux new-window \
        -n "ai-$AGENT_MODE" \
        "bash -lc '
            source \"$BASE_DIR/runtime/runtime.env\"

            export AI_PROMPT_FILE=\"$AI_PROMPT_FILE\"

            \"$HOME/dotfiles/scripts/ai/runtime/ai-runtime.sh\" \
                \"$PROVIDER\"

            exec zsh
        '"

    exit 0

fi

########################################
# STANDALONE EXECUTION
########################################

SESSION_NAME="$PROJECT_NAME"

tmux new-session \
    -d \
    -s "$SESSION_NAME" \
    "$HOME/dotfiles/scripts/ai/runtime/ai-runtime.sh \"$PROVIDER\" \"$HYDRATED_PROMPT\""

attach_runtime_session "$SESSION_NAME"

