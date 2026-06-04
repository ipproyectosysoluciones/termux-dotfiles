#!/usr/bin/env bats
# tests/phase6/docker_bootstrap.bats
# Verify docker bootstrap script for debian

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    BOOTSTRAP_SCRIPT="$PROJECT_ROOT/scripts/debian/bootstrap/docker.sh"
}

teardown() {
    :
}

@test "docker bootstrap script exists" {
    [[ -f "$BOOTSTRAP_SCRIPT" ]]
}

@test "docker bootstrap is executable" {
    [[ -x "$BOOTSTRAP_SCRIPT" ]]
}

@test "docker bootstrap uses set -euo pipefail" {
    head -1 "$BOOTSTRAP_SCRIPT" | grep -q '#!/bin/bash'
    grep -q 'set -euo pipefail' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap has DEPENDENCIES section" {
    grep -q 'DEPENDENCIES' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap installs required packages" {
    # Should install curl, ca-certificates, gnupg
    grep -q 'curl' "$BOOTSTRAP_SCRIPT"
    grep -q 'ca-certificates' "$BOOTSTRAP_SCRIPT"
    grep -q 'gnupg' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap has DOCKER section" {
    grep -q 'DOCKER' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap installs docker.io" {
    grep -q 'docker.io' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap has VERIFY section" {
    grep -q 'VERIFY' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap verifies with docker --version" {
    grep -q 'docker --version' "$BOOTSTRAP_SCRIPT"
}

@test "docker bootstrap follows kubernetes.sh pattern" {
    # Structure should match: DEPENDENCIES -> DOCKER -> VERIFY
    local deps_line docker_line verify_line
    deps_line=$(grep -n 'DEPENDENCIES' "$BOOTSTRAP_SCRIPT" | head -1 | cut -d: -f1)
    docker_line=$(grep -n 'DOCKER' "$BOOTSTRAP_SCRIPT" | head -1 | cut -d: -f1)
    verify_line=$(grep -n 'VERIFY' "$BOOTSTRAP_SCRIPT" | head -1 | cut -d: -f1)

    [[ "$deps_line" -lt "$docker_line" ]]
    [[ "$docker_line" -lt "$verify_line" ]]
}