#!/usr/bin/env bats

# Tests for claude.sh provider
# TDD: RED (tests written first) → GREEN (implementation passes) → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_provider claude)"

# Helper to create mock claude binary
create_mock_claude() {
    local mock_response="${1:-"claude response"}"
    local mock_status="${2:-0}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/claude" <<MOCK_CLAUDE
#!/usr/bin/env bash
# Mock claude command
# Echo the mock response
echo "$mock_response"
exit $mock_status
MOCK_CLAUDE
    chmod +x "$mock_dir/claude"
}

setup() {
    mkdir -p "$TEST_TMPDIR"
}

########################################
# RED: Write failing tests first
########################################

@test "run_claude - successful execution with env vars set" {
    # Given: mock claude returns success
    create_mock_claude "claude test response" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"
    export CLAUDE_PROJECT="test-project"
    export CLAUDE_AGENT="test-agent"
    export CLAUDE_SKILL="test-skill"
    export CLAUDE_WORKSPACE="$TEST_TMPDIR/workspace"

    run run_claude "test prompt"
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "claude test response" ]]
}

@test "run_claude - missing claude binary returns error" {
    # Given: empty mock dir (no claude)
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"
    unset CLAUDE_PROJECT CLAUDE_AGENT CLAUDE_SKILL CLAUDE_WORKSPACE

    run run_claude "test prompt" 2>&1
    export PATH="$old_path"

    [[ $status -ne 0 ]]
    # When claude is not found, run returns 127 and output contains the error
    [[ "$output" == *"command not found"* ]] || [[ "$status" -eq 127 ]]
}

@test "run_claude - env var propagation to claude call" {
    # Given: env vars set, mock claude echoes what it receives
    create_mock_claude "received prompt with env" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"
    export CLAUDE_PROJECT="my-project"
    export CLAUDE_AGENT="my-agent"
    export CLAUDE_SKILL="my-skill"
    export CLAUDE_WORKSPACE="$TEST_TMPDIR"

    run run_claude "test prompt"
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "received prompt with env" ]]
}

@test "run_claude - default env vars when not set" {
    # Given: no CLAUDE_* env vars set
    unset CLAUDE_PROJECT CLAUDE_AGENT CLAUDE_SKILL CLAUDE_WORKSPACE
    create_mock_claude "claude default envs" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_claude "test prompt"
    export PATH="$old_path"

    [[ $status -eq 0 ]]
}

@test "run_claude - invalid arguments handled" {
    # Given
    create_mock_claude "claude response" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"
    unset CLAUDE_PROJECT CLAUDE_AGENT CLAUDE_SKILL CLAUDE_WORKSPACE

    # When: calling with empty prompt
    run run_claude ""
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "claude response" ]]
}

@test "run_claude - non-zero exit status from claude propagates" {
    # Given: mock claude returns error
    create_mock_claude "claude error output" 1
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_claude "test prompt" 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == "claude error output" ]]
}