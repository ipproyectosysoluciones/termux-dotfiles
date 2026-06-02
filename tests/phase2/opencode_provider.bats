#!/usr/bin/env bats

# Tests for opencode.sh provider
# TDD: RED (tests written first) → GREEN (implementation passes) → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_provider opencode)"

# Helper to create mock opencode binary
create_mock_opencode() {
    local mock_response="${1:-"opencode response"}"
    local mock_status="${2:-0}"
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/opencode" <<MOCK_OPENCODE
#!/usr/bin/env bash
# Mock opencode command
echo "$mock_response"
exit $mock_status
MOCK_OPENCODE
    chmod +x "$mock_dir/opencode"
}

setup() {
    mkdir -p "$TEST_TMPDIR"
}

########################################
# RED: Write failing tests first
########################################

@test "run_opencode - successful execution" {
    # Given: mock opencode returns success
    create_mock_opencode "opencode test response" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_opencode "test prompt"
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "opencode test response" ]]
}

@test "run_opencode - missing opencode binary returns error" {
    # Given: empty mock dir (no opencode)
    local mock_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$mock_dir"
    local old_path="$PATH"
    export PATH="$mock_dir"

    run run_opencode "test prompt" 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == *"[ai] opencode unavailable"* ]]
}

@test "run_opencode - empty prompt handled" {
    # Given
    create_mock_opencode "opencode empty prompt response" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_opencode ""
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "opencode empty prompt response" ]]
}

@test "run_opencode - with prompt containing special characters" {
    # Given
    create_mock_opencode "opencode processed special chars" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_opencode "test with 'quotes' and \"double quotes\" and \$(commands)"
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "opencode processed special chars" ]]
}

@test "run_opencode - non-zero exit status propagates" {
    # Given: mock opencode returns error
    create_mock_opencode "opencode error" 1
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_opencode "test prompt" 2>&1
    export PATH="$old_path"

    [[ $status -eq 1 ]]
    [[ "$output" == "opencode error" ]]
}

@test "run_opencode - multiline prompt handled" {
    # Given
    create_mock_opencode "opencode multiline response" 0
    local old_path="$PATH"
    export PATH="$TEST_TMPDIR/mock_bin:$PATH"

    run run_opencode $'line1\nline2\nline3'
    export PATH="$old_path"

    [[ $status -eq 0 ]]
    [[ "$output" == "opencode multiline response" ]]
}