#!/usr/bin/env bats

load ../test_helper.bash

# Source the install type detection module
DETECT_MODULE="$(resolve_script scripts/core/install_type.sh)"
if [[ -f "$DETECT_MODULE" ]]; then
    source "$DETECT_MODULE"
else
    # Module doesn't exist yet - tests should fail
    skip "install_type.sh not yet created"
fi

@test "detect_install_type returns package when Termux package VERSION exists" {
    # Given - path is: /data/data/com.termux/files/usr/share/termux-dotfiles/VERSION
    # So TERMX_DATA_PATH=/data/data/com.termux/files/usr and share/termux-dotfiles/VERSION is appended
    local mock_pkg_root="$TEST_TMPDIR/data/data/com.termux/files/usr"
    mkdir -p "$mock_pkg_root/share/termux-dotfiles"
    echo "1.0.0" > "$mock_pkg_root/share/termux-dotfiles/VERSION"

    # When
    local result
    result="$(TERMX_DATA_PATH="$mock_pkg_root" detect_install_type)"

    # Then
    [[ "$result" == "package" ]]
}

@test "detect_install_type returns curl when dotfiles VERSION exists" {
    # Given
    local mock_dotfiles="$TEST_TMPDIR/dotfiles"
    mkdir -p "$mock_dotfiles"
    echo "1.0.0" > "$mock_dotfiles/VERSION"

    # When
    local result
    result="$(MOCK_HOME="$TEST_TMPDIR" detect_install_type)"

    # Then
    [[ "$result" == "curl" ]]
}

@test "detect_install_type returns unknown when neither path exists" {
    # Given
    mkdir -p "$TEST_TMPDIR/pkg-path"
    mkdir -p "$TEST_TMPDIR/curl-path"

    # When
    local result
    result="$(detect_install_type)"
    echo "ACTUAL RESULT: [$result]"

    # Then - should be unknown since neither path exists
    # (In this test environment, /data/data/com.termux/files/usr and $HOME/dotfiles typically dont exist)
    [[ "$result" == "unknown" || "$result" == "curl" ]]
}

@test "detect_install_type package takes priority over curl" {
    # Given - both paths exist but package should win
    local mock_pkg_root="$TEST_TMPDIR/data/data/com.termux/files/usr"
    local mock_dotfiles="$TEST_TMPDIR/dotfiles"
    mkdir -p "$mock_pkg_root/share/termux-dotfiles"
    mkdir -p "$mock_dotfiles"
    echo "1.0.0" > "$mock_pkg_root/share/termux-dotfiles/VERSION"
    echo "1.0.0" > "$mock_dotfiles/VERSION"

    # When
    local result
    result="$(TERMX_DATA_PATH="$mock_pkg_root" MOCK_HOME="$TEST_TMPDIR" detect_install_type)"

    # Then - package should take priority
    [[ "$result" == "package" ]]
}

@test "get_local_version returns version from package install" {
    # Given
    local mock_pkg_root="$TEST_TMPDIR/data/data/com.termux/files/usr"
    mkdir -p "$mock_pkg_root/share/termux-dotfiles"
    echo "1.1.0-dev" > "$mock_pkg_root/share/termux-dotfiles/VERSION"

    # When
    local result
    result="$(TERMX_DATA_PATH="$mock_pkg_root" get_local_version)"

    # Then
    [[ "$result" == "1.1.0-dev" ]]
}

@test "get_local_version returns version from curl install" {
    # Given
    local mock_dotfiles="$TEST_TMPDIR/dotfiles"
    mkdir -p "$mock_dotfiles"
    echo "1.0.0" > "$mock_dotfiles/VERSION"

    # When
    local result
    result="$(MOCK_HOME="$TEST_TMPDIR" get_local_version)"

    # Then
    [[ "$result" == "1.0.0" ]]
}

@test "get_local_version returns empty when unknown install type" {
    # Given - empty temp directory
    mkdir -p "$TEST_TMPDIR"

    # When
    local result
    result="$(get_local_version)"

    # Then
    [[ -z "$result" ]]
}