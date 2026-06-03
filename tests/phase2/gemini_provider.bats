#!/usr/bin/env bats

# Tests for gemini.sh provider
# TDD: RED (tests written first) → GREEN (implementation passes) → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_provider gemini)"

# Also source opencode and gentle for fallback testing
source "$(resolve_provider opencode)"
source "$(resolve_provider gentle)"

# Helper to create mock gemini binary
create_mock_gemini() {
    local mock_response="${1:-"gemini response"}"
    local mock_status="${2:-0}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/gemini" <<MOCK_GEMINI
#!/usr/bin/env bash
# Mock gemini command
# Echo the mock response
echo "$mock_response"
exit $mock_status
MOCK_GEMINI
    chmod +x "$mock_dir/gemini"
}

# Helper to create mock opencode binary for fallback testing
create_mock_opencode() {
    local mock_response="${1:-"opencode response"}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/opencode" <<MOCK_OPENCODE
#!/usr/bin/env bash
echo "[mock-opencode] $mock_response"
exit 0
MOCK_OPENCODE
    chmod +x "$mock_dir/opencode"
}

# Helper to create mock gentle-ai binary for fallback testing
# NOTE: must be named gentle-ai because run_gentle checks for that binary name
create_mock_gentle() {
    local mock_response="${1:-"gentle response"}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/gentle-ai" <<MOCK_GENTLE
#!/usr/bin/env bash
echo "[mock-gentle-ai] $mock_response"
exit 0
MOCK_GENTLE
    chmod +x "$mock_dir/gentle-ai"
}

setup() {
    mkdir -p "$TEST_TMPDIR"
    # Default: no mock binaries
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"
}

teardown() {
    remove_mocks_from_path
}

########################################
# RED: Write failing tests first
########################################

@test "run_gemini - successful execution with valid prompt" {
    # Given: mock gemini returns success
    create_mock_gemini "gemini test response" 0
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When
    local output
    output="$(run_gemini "test prompt")"
    local status=$?

    # Then: should return success and output
    [[ $status -eq 0 ]]
    [[ "$output" == "gemini test response" ]]
}

@test "run_gemini - QUOTA_EXHAUSTED triggers fallback to opencode" {
    # Given: mock gemini returns QUOTA_EXHAUSTED
    create_mock_gemini "QUOTA_EXHAUSTED" 0
    create_mock_opencode "fallback opencode response"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When
    local output
    output="$(run_gemini "test prompt")"
    local status=$?

    # Then: should fallback to opencode
    [[ $status -eq 0 ]]
    [[ "$output" == *"[mock-opencode]"* ]]
    [[ "$output" == *"fallback opencode response"* ]]
}

@test "run_gemini - generic failure triggers fallback to gentle" {
    # Given: mock gemini returns error
    create_mock_gemini "ERROR" 1
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When: calling run_gemini with failing gemini
    run run_gemini "test prompt"

    # Then: should fallback to gentle gracefully
    [[ $status -eq 0 ]]
    [[ "$output" == *"falling back to gentle"* ]]
}

@test "run_gemini - missing API key (GEMINI_API_KEY not set) - graceful handling" {
    # Given: mock gemini returns error (simulating missing API key)
    unset GEMINI_API_KEY
    create_mock_gemini "error: API key not configured" 1

    # When: calling run_gemini with failing gemini
    # The fallback chain: gemini fails -> falls back to gentle
    run run_gemini "test prompt"

    # Then: should handle gracefully via fallback
    [[ $status -eq 0 ]]
    [[ "$output" == *"falling back to gentle"* ]]
}

@test "run_gemini - empty prompt handled gracefully" {
    # Given
    create_mock_gemini "response for empty prompt" 0
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When
    local output
    output="$(run_gemini "")"
    local status=$?

    # Then
    [[ $status -eq 0 ]]
    [[ "$output" == "response for empty prompt" ]]
}

@test "run_gemini - QUOTA_EXHAUSTED case insensitive is detected" {
    # Given: mock gemini output with lowercase quota exhausted
    create_mock_gemini "quota_exhausted detected" 0
    create_mock_opencode "opencode fallback"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When
    local output
    output="$(run_gemini "test prompt")"
    local status=$?

    # Then: case insensitive detection should trigger fallback
    [[ $status -eq 0 ]]
    [[ "$output" == *"[mock-opencode]"* ]]
}

@test "run_gemini - fallback chain preserves output from fallback provider" {
    # Given: mock gemini fails with quota exhausted
    create_mock_gemini "ERROR: QUOTA_EXHAUSTED" 0
    create_mock_opencode "primary fallback worked"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    # When
    local output
    output="$(run_gemini "test prompt")"

    # Then: output should contain fallback result
    [[ "$output" == *"primary fallback worked"* ]]
}
