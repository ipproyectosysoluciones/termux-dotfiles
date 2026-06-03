#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core project)"

@test "detect_project finds git project root" {
    # Given
    local test_dir="$TEST_TMPDIR/git-project"
    mkdir -p "$test_dir/.git"
    mkdir -p "$test_dir/subdir/nested"

    # When
    local result
    result="$(cd "$test_dir/subdir/nested" && detect_project)"

    # Then
    [[ "$result" == "$test_dir" ]]
}

@test "detect_project finds node project root" {
    # Given
    local test_dir="$TEST_TMPDIR/node-project"
    mkdir -p "$test_dir/src"
    echo '{"name":"test-project"}' > "$test_dir/package.json"

    # When
    local result
    result="$(cd "$test_dir/src" && detect_project)"

    # Then
    [[ "$result" == "$test_dir" ]]
}

@test "detect_project finds docker project root" {
    # Given
    local test_dir="$TEST_TMPDIR/docker-project"
    mkdir -p "$test_dir/subdir"
    echo "version: '3'" > "$test_dir/docker-compose.yml"

    # When
    local result
    result="$(cd "$test_dir/subdir" && detect_project)"

    # Then
    [[ "$result" == "$test_dir" ]]
}

@test "detect_project finds rust project root" {
    # Given
    local test_dir="$TEST_TMPDIR/rust-project"
    mkdir -p "$test_dir/src/bin"
    echo "[package]" > "$test_dir/Cargo.toml"
    echo 'name = "test"' >> "$test_dir/Cargo.toml"

    # When
    local result
    result="$(cd "$test_dir/src/bin" && detect_project)"

    # Then
    [[ "$result" == "$test_dir" ]]
}

@test "detect_project finds python project root" {
    # Given
    local test_dir="$TEST_TMPDIR/python-project"
    mkdir -p "$test_dir/tests/unit"
    echo "pytest==7.0.0" > "$test_dir/requirements.txt"

    # When
    local result
    result="$(cd "$test_dir/tests/unit" && detect_project)"

    # Then
    [[ "$result" == "$test_dir" ]]
}

@test "detect_project falls back to PWD when no project marker found" {
    # Given
    local test_dir="$TEST_TMPDIR/orphan-dir"
    mkdir -p "$test_dir/subdir"

    # When
    local result
    result="$(cd "$test_dir/subdir" && detect_project)"

    # Then
    [[ "$result" == "$test_dir/subdir" ]]
}

@test "project_name extracts basename from path" {
    # Given
    local test_path="/home/user/my-project"

    # When
    local result
    result="$(project_name "$test_path")"

    # Then
    [[ "$result" == "my-project" ]]
}

@test "project_name returns root for root directory" {
    # Given
    local test_path="/"

    # When
    local result
    result="$(project_name "$test_path")"

    # Then - basename of / returns /
    [[ "$result" == "/" ]]
}

@test "project_type returns node for node project" {
    # Given
    local test_dir="$TEST_TMPDIR/node-type"
    mkdir -p "$test_dir"
    echo '{"name":"test"}' > "$test_dir/package.json"

    # When
    local result
    result="$(project_type "$test_dir")"

    # Then
    [[ "$result" == "node" ]]
}

@test "project_type returns rust for rust project" {
    # Given
    local test_dir="$TEST_TMPDIR/rust-type"
    mkdir -p "$test_dir"
    echo "[package]" > "$test_dir/Cargo.toml"
    echo 'name = "test"' >> "$test_dir/Cargo.toml"

    # When
    local result
    result="$(project_type "$test_dir")"

    # Then
    [[ "$result" == "rust" ]]
}

@test "project_type returns python for python project" {
    # Given
    local test_dir="$TEST_TMPDIR/python-type"
    mkdir -p "$test_dir"
    echo "pytest==7.0.0" > "$test_dir/requirements.txt"

    # When
    local result
    result="$(project_type "$test_dir")"

    # Then
    [[ "$result" == "python" ]]
}

@test "project_type returns docker for docker project" {
    # Given
    local test_dir="$TEST_TMPDIR/docker-type"
    mkdir -p "$test_dir"
    echo "version: '3'" > "$test_dir/docker-compose.yml"

    # When
    local result
    result="$(project_type "$test_dir")"

    # Then
    [[ "$result" == "docker" ]]
}

@test "project_type returns generic for unknown project" {
    # Given
    local test_dir="$TEST_TMPDIR/generic-type"
    mkdir -p "$test_dir"

    # When
    local result
    result="$(project_type "$test_dir")"

    # Then
    [[ "$result" == "generic" ]]
}

@test "git_branch returns current branch in git repo" {
    # Given
    local test_dir="$TEST_TMPDIR/git-branch-test"
    mkdir -p "$test_dir/.git"
    cd "$test_dir"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    git commit -q --allow-empty -m "initial"

    # When
    local result
    result="$(git_branch "$test_dir")"

    # Then
    [[ "$result" == "main" ]]
}

@test "git_branch returns no-git when not a git repo" {
    # Given
    local test_dir="$TEST_TMPDIR/no-git-test"
    mkdir -p "$test_dir"

    # When
    local result
    result="$(git_branch "$test_dir")"

    # Then
    [[ "$result" == "no-git" ]]
}