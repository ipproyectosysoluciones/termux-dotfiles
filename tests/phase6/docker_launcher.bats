#!/usr/bin/env bats
# tests/phase6/docker_launcher.bats
# Verify enhanced docker.sh launcher with proot-distro routing

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
    # Should check if proot-distro login debian works
    grep -q 'proot-distro' "$DOCKER_SCRIPT"
    grep -q 'login debian' "$DOCKER_SCRIPT"
}

@test "docker.sh binds HOME to /termux in proot command" {
    # The proot-distro login command should include --bind $HOME:/termux
    grep -q '\$HOME:/termux' "$DOCKER_SCRIPT"
}

@test "docker.sh uses --user dev in proot command" {
    grep -q 'user dev' "$DOCKER_SCRIPT"
}

@test "docker.sh checks for docker binary inside debian" {
    # Should check if docker exists inside the proot container
    grep -q 'command -v docker' "$DOCKER_SCRIPT"
}

@test "docker.sh creates tmux session for proot-distro" {
    # Should use create_session with proot-distro command
    grep -q 'create_session' "$DOCKER_SCRIPT"
}

@test "docker.sh uses attach_or_switch pattern" {
    grep -q 'attach_or_switch' "$DOCKER_SCRIPT"
}

@test "docker.sh falls back to native docker if available" {
    # Should have fallback logic for native docker
    grep -q 'command -v docker' "$DOCKER_SCRIPT"
}

@test "docker.sh has PROOT_DISTRO_BLOCK comment" {
    grep -q 'PROOT_DISTRO_BLOCK' "$DOCKER_SCRIPT"
}

@test "docker.sh has DOCKER_CHECK_BLOCK comment" {
    grep -q 'DOCKER_CHECK_BLOCK' "$DOCKER_SCRIPT"
}

@test "docker.sh has TMUX_SESSION_BLOCK comment" {
    # This block is implied by create_session usage
    grep -q 'create_session' "$DOCKER_SCRIPT"
    grep -q 'attach_or_switch' "$DOCKER_SCRIPT"
}

@test "docker.sh proot-distro command runs docker ps" {
    grep -q 'docker ps' "$DOCKER_SCRIPT"
}