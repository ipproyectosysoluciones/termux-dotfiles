#!/usr/bin/env bats

# Tests for gentle.sh provider
# TDD: RED (tests written first) → GREEN (implementation passes) → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_provider gentle)"

# Helper to create mock gentle-ai binary
create_mock_gentle_ai() {
    local mock_response="${1:-"gentle-ai response"}"
    local mock_status="${2:-0}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/gentle-ai" <<MOCK_GENTLE
#!/usr/bin/env bash
# Mock gentle-ai command
echo "$mock_response"
exit $mock_status
MOCK_GENTLE
    chmod +x "$mock_dir/gentle-ai"
}

setup() {
    mkdir -p "$TEST_TMPDIR"
}

########################################
# RED: Write failing tests first
########################################

@test "gentle_sync - successful sync" {
    # Given: mock gentle-ai returns success
    create_mock_gentle_ai "sync completed successfully" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_sync 2>&1
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "sync completed successfully" ]]
}

@test "gentle_sync - missing gentle-ai binary returns error" {
    # Given: empty mock dir (no gentle-ai)
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"

    run gentle_sync 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "gentle_upgrade - successful upgrade" {
    # Given: mock gentle-ai returns success
    create_mock_gentle_ai "upgrade completed successfully" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_upgrade 2>&1
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "upgrade completed successfully" ]]
}

@test "gentle_upgrade - missing gentle-ai binary returns error" {
    # Given: empty mock dir (no gentle-ai)
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"

    run gentle_upgrade 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "gentle_refresh_skills - successful refresh" {
    # Given: mock gentle-ai returns success
    create_mock_gentle_ai "skills refreshed successfully" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_refresh_skills 2>&1
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "skills refreshed successfully" ]]
}

@test "gentle_refresh_skills - missing gentle-ai binary returns error" {
    # Given: empty mock dir (no gentle-ai)
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"

    run gentle_refresh_skills 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "gentle_sync - non-zero exit status propagates" {
    # Given: mock gentle-ai returns error
    create_mock_gentle_ai "sync failed" 1
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_sync 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == "sync failed" ]]
}

@test "gentle_upgrade - non-zero exit status propagates" {
    # Given: mock gentle-ai returns error
    create_mock_gentle_ai "upgrade failed" 1
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_upgrade 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == "upgrade failed" ]]
}

@test "gentle_refresh_skills - non-zero exit status propagates" {
    # Given: mock gentle-ai returns error
    create_mock_gentle_ai "refresh failed" 1
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run gentle_refresh_skills 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == "refresh failed" ]]
}

########################################
# RUN GENTLE (PROVIDER INTERFACE)
########################################

@test "run_gentle - returns control-plane message when gentle-ai available" {
    # Given: gentle-ai binary exists
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"
    cat > "$mock_dir/gentle-ai" <<MOCK_GENTLEAI
#!/usr/bin/env bash
echo "gentle-ai control plane"
exit 0
MOCK_GENTLEAI
    chmod +x "$mock_dir/gentle-ai"
    local old_path="$PATH"
    export PATH="$mock_dir:$PATH"

    run run_gentle "test prompt"
    export PATH="$old_path"

    # Then: should return 1 and show control-plane message
    [[ $status -eq 1 ]]
    [[ "$output" == *"control-plane tool"* ]]
    [[ "$output" == *"does not accept prompts"* ]]
}

@test "run_gentle - missing gentle-ai binary returns error" {
    # Given: no gentle-ai in PATH
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"

    run run_gentle "test prompt"
    export PATH="$old_path"

    # Then: should return 1
    [[ $status -eq 1 ]]
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}
