#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core sync)"

# Override directories for testing
setup() {
    setup_test_env
    export SYNC_ROOT="$TEST_TMPDIR/sync"
    export DEBIAN_WORKSPACE_ROOT="$TEST_TMPDIR/workspaces"
    export HOME="$TEST_TMPDIR"
}

teardown() {
    teardown_test_env
}

@test "sync_project_path returns correct sync path for project" {
    # Given
    local project="my-project"

    # When
    local result
    result="$(sync_project_path "$project")"

    # Then
    [[ "$result" == "$SYNC_ROOT/my-project" ]]
}

@test "sync_project_path handles empty project name" {
    # When
    local result
    result="$(sync_project_path "")"

    # Then
    [[ "$result" == "$SYNC_ROOT/"* ]]
}

@test "sync_project_path handles project with slashes" {
    # Given
    local project="path/to/project"

    # When
    local result
    result="$(sync_project_path "$project")"

    # Then
    [[ "$result" == "$SYNC_ROOT/path/to/project" ]]
}

@test "ensure_sync_root creates SYNC_ROOT if it doesn't exist" {
    # Given - SYNC_ROOT points to non-existent directory
    export SYNC_ROOT="$TEST_TMPDIR/new-sync-root"
    [[ ! -d "$SYNC_ROOT" ]]

    # When
    ensure_sync_root

    # Then
    [[ -d "$SYNC_ROOT" ]]
}

@test "ensure_sync_root succeeds when directory already exists" {
    # Given
    mkdir -p "$SYNC_ROOT"

    # When
    local exit_code
    ensure_sync_root
    exit_code=$?

    # Then
    [[ "$exit_code" -eq 0 ]]
}

@test "mirror_project creates mirror directory structure" {
    # Given
    local source="$TEST_TMPDIR/source-project"
    local project="mirror-test"
    mkdir -p "$source/subdir"
    echo "test content" > "$source/subdir/file.txt"

    # When
    mirror_project "$source" "$project"

    # Then
    [[ -d "$SYNC_ROOT/$project" ]]
    [[ -f "$SYNC_ROOT/$project/subdir/file.txt" ]]
}

@test "mirror_project copies all files from source" {
    # Given
    local source="$TEST_TMPDIR/source"
    local project="copy-test"
    mkdir -p "$source"
    echo "file1" > "$source/file1.txt"
    echo "file2" > "$source/file2.txt"

    # When
    mirror_project "$source" "$project"

    # Then
    [[ -f "$SYNC_ROOT/$project/file1.txt" ]]
    [[ -f "$SYNC_ROOT/$project/file2.txt" ]]
}

@test "mirror_project overwrites existing files" {
    # Given
    local source="$TEST_TMPDIR/source2"
    local project="overwrite-test"
    mkdir -p "$source"
    echo "new content" > "$source/new.txt"
    mkdir -p "$SYNC_ROOT/$project"
    echo "old content" > "$SYNC_ROOT/$project/new.txt"

    # When
    mirror_project "$source" "$project"

    # Then
    [[ "$(cat "$SYNC_ROOT/$project/new.txt")" == "new content" ]]
}

@test "provider_workspace returns correct provider workspace" {
    # Given
    local project="test-workspace"

    # When
    local result
    result="$(provider_workspace "$project")"

    # Then
    [[ "$result" == "$DEBIAN_WORKSPACE_ROOT/test-workspace" ]]
}

@test "provider_workspace handles empty project name" {
    # When
    local result
    result="$(provider_workspace "")"

    # Then
    [[ "$result" == "$DEBIAN_WORKSPACE_ROOT/"* ]]
}

@test "provider_workspace handles special characters in project name" {
    # Given
    local project="my-project_v1"

    # When
    local result
    result="$(provider_workspace "$project")"

    # Then
    [[ "$result" == "$DEBIAN_WORKSPACE_ROOT/my-project_v1" ]]
}

@test "sync_project_path uses SYNC_ROOT environment variable" {
    # Given
    export SYNC_ROOT="/custom/sync/root"
    local project="test"

    # When
    local result
    result="$(sync_project_path "$project")"

    # Then
    [[ "$result" == "/custom/sync/root/test" ]]
}