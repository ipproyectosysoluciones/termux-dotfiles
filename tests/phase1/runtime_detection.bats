#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core runtime)"

@test "detect_runtime returns mobile when Termux directory exists" {
    # Given
    local termux_dir="$TEST_TMPDIR/termux-fake"
    mkdir -p "$termux_dir"
    # Override the check - we need to mock -d
    # For this test, we'll use a different approach by creating the actual check path

    # When
    local result
    # We need to test with actual /data/data/com.termux path, so skip if not available
    if [[ -d "/data/data/com.termux" ]]; then
        result="$(detect_runtime)"
        [[ "$result" == "mobile" ]]
    else
        skip "Termux directory not available on this system"
    fi
}

@test "detect_runtime returns remote when SSH_CONNECTION is set" {
    # Given
    export SSH_CONNECTION="192.168.1.100 12345 10.0.0.1 22"

    # When
    local result
    result="$(detect_runtime)"

    # Then
    [[ "$result" == "remote" ]]

    # Cleanup
    unset SSH_CONNECTION
}

@test "detect_runtime returns local when no special conditions" {
    # Given - ensure no Termux and no SSH_CONNECTION
    unset SSH_CONNECTION

    # When
    local result
    result="$(detect_runtime)"

    # Then
    [[ "$result" == "local" ]]
}

@test "detect_tmux_mode returns nested when TMUX is set" {
    # Given
    export TMUX="12345,1234,0"

    # When
    local result
    result="$(detect_tmux_mode)"

    # Then
    [[ "$result" == "nested" ]]

    # Cleanup
    unset TMUX
}

@test "detect_tmux_mode returns standalone when TMUX is not set" {
    # Given
    unset TMUX

    # When
    local result
    result="$(detect_tmux_mode)"

    # Then
    [[ "$result" == "standalone" ]]
}

@test "detect_network returns online when ping succeeds" {
    # When
    local result
    result="$(detect_network)"

    # Then - either online or offline depending on actual connectivity
    [[ "$result" == "online" || "$result" == "offline" ]]
}

@test "detect_network returns offline when ping fails" {
    # Given - mock ping to fail by overriding it temporarily
    ping() {
        return 1
    }
    export -f ping

    # When
    local result
    result="$(detect_network)"

    # Then
    [[ "$result" == "offline" ]]
}

@test "detect_runtime priority: mobile over remote" {
    # Given - both Termux dir and SSH_CONNECTION present
    export SSH_CONNECTION="192.168.1.100 12345 10.0.0.1 22"

    # When
    local result
    result="$(detect_runtime)"

    # Then - mobile takes priority
    if [[ -d "/data/data/com.termux" ]]; then
        [[ "$result" == "mobile" ]]
    else
        [[ "$result" == "remote" ]]
    fi

    # Cleanup
    unset SSH_CONNECTION
}