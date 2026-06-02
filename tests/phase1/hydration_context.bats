#!/usr/bin/env bats

load ../test_helper.bash

# Source the modules under test
source "$(resolve_core hydration)"
source "$(resolve_core memory)"
source "$(resolve_core sync)"
source "$(resolve_core state)"

# Override directories for testing
setup() {
    setup_test_env
    export STATE_DIR="$TEST_TMPDIR/state"
    export SYNC_ROOT="$TEST_TMPDIR/sync"
    export HOME="$TEST_TMPDIR"
    export DEBIAN_WORKSPACE_ROOT="$TEST_TMPDIR/workspaces"
    export PROJECT_NAME="test-project"
    export GIT_BRANCH="main"
    mkdir -p "$STATE_DIR"
    mkdir -p "$SYNC_ROOT"
    mkdir -p "$DEBIAN_WORKSPACE_ROOT"

    # Create mock engram if available
    if command -v engram >/dev/null 2>&1; then
        create_mock_engram
        add_mocks_to_path
    fi
}

teardown() {
    remove_mocks_from_path
    teardown_test_env
}

@test "build_context includes project info" {
    # Given
    local prompt="test prompt"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"Project: test-project"* ]]
}

@test "build_context includes branch info" {
    # Given
    local prompt="test prompt"
    export GIT_BRANCH="feature/test"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"Branch: feature/test"* ]]
}

@test "build_context includes user request" {
    # Given
    local prompt="my specific request"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"User request:"* ]]
    [[ "$output" == *"my specific request"* ]]
}

@test "build_context works with empty memory" {
    # Given - memory returns empty when engram not available
    local prompt="test prompt"
    export GIT_BRANCH="develop"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"Relevant memory:"* ]]
    [[ "$output" == *"Project root:"* ]]
}

@test "build_context includes provider workspace path" {
    # Given
    local prompt="test prompt"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"Project root:"*"/"* ]]
}

@test "build_context uses PROJECT_NAME variable" {
    # Given
    local prompt="test"
    export PROJECT_NAME="my-special-project"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"Project: my-special-project"* ]]
}

@test "build_context handles missing GIT_BRANCH" {
    # Given
    local prompt="test"
    unset GIT_BRANCH

    # When
    local output
    output="$(build_context "$prompt")" 2>/dev/null || true

    # Then - script should still run (branch might be empty)
    [[ -n "$output" ]]
}

@test "build_context completes successfully" {
    # Given
    local prompt="test prompt"

    # When
    local output
    output="$(build_context "$prompt")"

    # Then
    [[ "$output" == *"[hydration] completed"* ]]
}