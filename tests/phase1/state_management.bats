#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core state)"

# Override STATE_DIR for testing
setup() {
    setup_test_env
    export STATE_DIR="$TEST_TMPDIR/state"
    mkdir -p "$STATE_DIR"
}

teardown() {
    teardown_test_env
}

@test "save_current_workspace writes state file" {
    # Given
    local session="test-session"
    local project="test-project"
    local root="/tmp/test"
    local type="node"
    local branch="main"
    local layout="default"

    # When
    save_current_workspace "$session" "$project" "$root" "$type" "$branch" "$layout"

    # Then
    [[ -f "$STATE_DIR/current_workspace" ]]
}

@test "save_current_workspace contains all parameters" {
    # Given
    local session="my-session"
    local project="my-project"
    local root="/my/root"
    local type="rust"
    local branch="develop"
    local layout="mobile"

    # When
    save_current_workspace "$session" "$project" "$root" "$type" "$branch" "$layout"

    # Then
    grep -q "SESSION_NAME=\"my-session\"" "$STATE_DIR/current_workspace"
    grep -q "PROJECT_NAME=\"my-project\"" "$STATE_DIR/current_workspace"
    grep -q "PROJECT_ROOT=\"/my/root\"" "$STATE_DIR/current_workspace"
    grep -q "PROJECT_TYPE=\"rust\"" "$STATE_DIR/current_workspace"
    grep -q "GIT_BRANCH=\"develop\"" "$STATE_DIR/current_workspace"
    grep -q "LAYOUT=\"mobile\"" "$STATE_DIR/current_workspace"
    grep -q "UPDATED_AT=" "$STATE_DIR/current_workspace"
}

@test "load_current_workspace returns 0 when file exists" {
    # Given
    local session="test-session"
    local project="test-project"
    local root="/tmp/test"
    local type="node"
    local branch="main"
    local layout="default"
    save_current_workspace "$session" "$project" "$root" "$type" "$branch" "$layout"

    # When
    local result
    load_current_workspace
    local exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "load_current_workspace sets variables correctly" {
    # Given
    local session="load-test-session"
    local project="load-test-project"
    local root="/load/test"
    local type="python"
    local branch="feature/test"
    local layout="node"
    save_current_workspace "$session" "$project" "$root" "$type" "$branch" "$layout"

    # When
    load_current_workspace

    # Then
    [[ "$SESSION_NAME" == "load-test-session" ]]
    [[ "$PROJECT_NAME" == "load-test-project" ]]
    [[ "$PROJECT_ROOT" == "/load/test" ]]
    [[ "$PROJECT_TYPE" == "python" ]]
    [[ "$GIT_BRANCH" == "feature/test" ]]
    [[ "$LAYOUT" == "node" ]]
}

@test "load_current_workspace returns 1 when file missing" {
    # Given - STATE_DIR is set but file doesn't exist

    # When
    local exit_code=0
    load_current_workspace || exit_code=$?

    # Then
    [[ "$exit_code" -eq 1 ]]
}

@test "clear_current_workspace removes state file" {
    # Given
    local session="clear-test"
    local project="clear-project"
    local root="/clear/root"
    local type="docker"
    local branch="main"
    local layout="default"
    save_current_workspace "$session" "$project" "$root" "$type" "$branch" "$layout"
    [[ -f "$STATE_DIR/current_workspace" ]]

    # When
    clear_current_workspace

    # Then
    [[ ! -f "$STATE_DIR/current_workspace" ]]
}

@test "clear_current_workspace succeeds when file doesn't exist" {
    # Given - no file created

    # When
    local exit_code
    clear_current_workspace
    exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "save_current_workspace overwrites existing state" {
    # Given - create initial state
    save_current_workspace "old-session" "old-project" "/old/root" "generic" "main" "default"
    [[ -f "$STATE_DIR/current_workspace" ]]

    # When - save new state
    save_current_workspace "new-session" "new-project" "/new/root" "node" "develop" "mobile"

    # Then - old data replaced
    grep -q "SESSION_NAME=\"new-session\"" "$STATE_DIR/current_workspace"
    ! grep -q "SESSION_NAME=\"old-session\"" "$STATE_DIR/current_workspace" || false
}