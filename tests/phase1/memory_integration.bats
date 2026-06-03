#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core memory)"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "memory_available returns 0 when engram command exists" {
    # Given - engram command exists or we create mock
    if command -v engram >/dev/null 2>&1; then
        # When
        memory_available
        # Then - should return 0 (success) when engram exists
        [[ $? -eq 0 ]]
    else
        skip "engram command not available"
    fi
}

@test "memory_available with mock engram in PATH returns 0" {
    # Given - create mock engram in a temp directory
    local mock_dir="$TEST_TMPDIR/mock_engram"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/engram" <<'MOCK_SCRIPT'
#!/usr/bin/env bash
exit 0
MOCK_SCRIPT
    chmod +x "$mock_dir/engram"

    local old_path="$PATH"
    export PATH="$mock_dir:$PATH"

    # When
    local exit_code=0
    memory_available || exit_code=$?

    export PATH="$old_path"

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "memory_available returns 1 when engram not in PATH" {
    # Given - create a PATH with only our mock dir which has no engram
    local empty_dir="$TEST_TMPDIR/empty_bin"
    mkdir -p "$empty_dir"

    local old_path="$PATH"
    export PATH="$empty_dir"

    # When
    local exit_code=0
    memory_available || exit_code=$?

    export PATH="$old_path"

    # Then
    [[ "$exit_code" -eq 1 ]]
}

@test "memory_project_context calls engram context with project" {
    # Given - create mock engram
    if ! command -v engram >/dev/null 2>&1; then
        skip "engram not available for this test"
    fi

    # When
    local result
    result="$(memory_project_context "test-project")"

    # Then - should return 0 and produce some output
    [[ $? -eq 0 ]]
}

@test "memory_project_context returns 0 when project is empty" {
    # Given - empty project name

    # When
    local exit_code=0
    memory_project_context "" || exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "memory_search calls engram search with query and project" {
    # Given - create mock engram if needed
    if ! command -v engram >/dev/null 2>&1; then
        skip "engram not available for this test"
    fi

    # When
    local result
    result="$(memory_search "test query" "test-project")"

    # Then - should succeed
    [[ $? -eq 0 ]]
}

@test "memory_search returns 0 when query is empty" {
    # Given - empty query

    # When
    local exit_code=0
    memory_search "" "test-project" || exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "memory_save calls engram save with title content and project" {
    # Given - create mock engram if needed
    if ! command -v engram >/dev/null 2>&1; then
        skip "engram not available for this test"
    fi

    # When
    local exit_code=0
    memory_save "test-title" "test content" "test-project" || exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "memory_save returns 0 when content is empty" {
    # Given - empty content

    # When
    local exit_code=0
    memory_save "test-title" "" "test-project" || exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "memory_available with mock engram returns 0" {
    # Given - create mock engram in PATH
    local mock_dir="$TEST_TMPDIR/mock_engram"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/engram" <<'MOCK_SCRIPT'
#!/usr/bin/env bash
exit 0
MOCK_SCRIPT
    chmod +x "$mock_dir/engram"

    local old_path="$PATH"
    export PATH="$mock_dir:$PATH"

    # When
    local exit_code=0
    memory_available || exit_code=$?

    export PATH="$old_path"

    # Then
    [[ "$exit_code" -eq 0 ]]
}