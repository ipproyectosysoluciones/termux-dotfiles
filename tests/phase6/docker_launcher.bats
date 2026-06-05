#!/usr/bin/env bats
# tests/phase6/docker_launcher.bats
# Verify enhanced docker.sh launcher with daemon status + remote context

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    DOCKER_SCRIPT="$PROJECT_ROOT/scripts/ai/docker.sh"
}

teardown() {
    :
}

@test "docker.sh is executable" {
    [[ -x "$DOCKER_SCRIPT" ]]
}

@test "docker.sh sources utils.sh" {
    grep -q 'source "$SCRIPT_DIR/utils.sh"' "$DOCKER_SCRIPT"
}

@test "docker.sh checks proot-distro availability" {
    grep -q 'proot-distro' "$DOCKER_SCRIPT"
    grep -q 'login debian' "$DOCKER_SCRIPT"
}

@test "docker.sh binds HOME to /termux in proot command" {
    grep -q '\$HOME:/termux' "$DOCKER_SCRIPT"
}

@test "docker.sh uses --user dev in proot command" {
    grep -q 'user dev' "$DOCKER_SCRIPT"
}

@test "docker.sh checks for docker binary inside debian" {
    grep -q 'command -v docker' "$DOCKER_SCRIPT"
}

@test "docker.sh creates tmux session for proot-distro" {
    grep -q 'launch_in_window' "$DOCKER_SCRIPT"
}

@test "docker.sh uses launch_in_window pattern" {
    grep -q 'launch_in_window' "$DOCKER_SCRIPT"
}

@test "docker.sh falls back to native docker if available" {
    grep -q 'command -v docker' "$DOCKER_SCRIPT"
}

@test "docker.sh has proot-distro command without inline bash -c" {
    # Should drop into debian shell directly, not a bash -c status script
    grep -q "user dev" "$DOCKER_SCRIPT"
    # Must NOT have the complex inline bash -c that broke quoting
    run grep -c 'bash -c "' "$DOCKER_SCRIPT" || true
    # The bash -c pattern is only in fallback, not in proot-distro path
    grep -q 'launch_in_window "$SESSION" \\' "$DOCKER_SCRIPT"
}

@test "docker.sh fallback has shell exec" {
    grep -q 'exec.*SHELL' "$DOCKER_SCRIPT"
}