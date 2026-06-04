#!/usr/bin/env bats
# tests/phase6/docker_infra_template.bats
# Verify infra.sh template for docker project_type

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    TEMPLATE_SCRIPT="$PROJECT_ROOT/scripts/ai/templates/infra.sh"
}

teardown() {
    :
}

@test "infra.sh template exists" {
    [[ -f "$TEMPLATE_SCRIPT" ]]
}

@test "infra.sh is executable" {
    [[ -x "$TEMPLATE_SCRIPT" ]]
}

@test "infra.sh has build_layout function" {
    grep -q '^build_layout()' "$TEMPLATE_SCRIPT"
}

@test "infra.sh creates server tmux window" {
    # server window is created via rename (window 0), not new-window
    grep -q 'tmux rename-window.*"server"' "$TEMPLATE_SCRIPT"
    grep -q 'docker ps' "$TEMPLATE_SCRIPT"
}

@test "infra.sh creates editor tmux window" {
    grep -Pzo 'tmux new-window[\s\S]*?-n "editor"' "$TEMPLATE_SCRIPT" > /dev/null
}

@test "infra.sh creates claude tmux window" {
    grep -Pzo 'tmux new-window[\s\S]*?-n "claude"' "$TEMPLATE_SCRIPT" > /dev/null
}

@test "infra.sh creates gemini tmux window" {
    grep -Pzo 'tmux new-window[\s\S]*?-n "gemini"' "$TEMPLATE_SCRIPT" > /dev/null
}

@test "infra.sh server window runs docker ps monitoring" {
    grep -q 'docker ps' "$TEMPLATE_SCRIPT"
}

@test "infra.sh follows node.sh pattern" {
    grep -q '^build_layout()' "$TEMPLATE_SCRIPT"
    grep -q 'tmux rename-window' "$TEMPLATE_SCRIPT"
    grep -Pzo 'tmux new-window[\s\S]*?-n "editor"' "$TEMPLATE_SCRIPT" > /dev/null
    grep -Pzo 'tmux new-window[\s\S]*?-n "claude"' "$TEMPLATE_SCRIPT" > /dev/null
    grep -Pzo 'tmux new-window[\s\S]*?-n "gemini"' "$TEMPLATE_SCRIPT" > /dev/null
    grep -q 'tmux select-window' "$TEMPLATE_SCRIPT"
}

@test "infra.sh accepts session parameter" {
    grep -q 'local session="$1"' "$TEMPLATE_SCRIPT"
}