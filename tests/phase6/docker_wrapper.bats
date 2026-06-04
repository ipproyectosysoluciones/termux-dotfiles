#!/usr/bin/env bats
# tests/phase6/docker_wrapper.bats
# Verify docker wrapper is installed via wrappers.sh

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    WRAPPERS_SCRIPT="$PROJECT_ROOT/scripts/debian/wrappers.sh"
}

teardown() {
    # No persistent state to clean
    :
}

@test "wrappers.sh contains create_wrapper docker" {
    grep -q 'create_wrapper docker' "$WRAPPERS_SCRIPT"
}

@test "docker wrapper call is after kubernetes section" {
    # Line with create_wrapper docker should come after kubectl and helm
    local docker_line
    docker_line=$(grep -n 'create_wrapper docker' "$WRAPPERS_SCRIPT" | cut -d: -f1)
    [[ -n "$docker_line" ]]

    # kubectl is around line 61, helm is around line 62
    # docker should come after both
    local kubectl_line helm_line
    kubectl_line=$(grep -n 'create_wrapper kubectl' "$WRAPPERS_SCRIPT" | cut -d: -f1)
    helm_line=$(grep -n 'create_wrapper helm' "$WRAPPERS_SCRIPT" | cut -d: -f1)

    [[ "$docker_line" -gt "$kubectl_line" ]]
    [[ "$docker_line" -gt "$helm_line" ]]
}

@test "wrappers.sh has kubernetes section before docker" {
    # Verify structure: KUBERNETES section then docker wrapper
    grep -q 'KUBERNETES' "$WRAPPERS_SCRIPT"
    grep -q 'create_wrapper docker' "$WRAPPERS_SCRIPT"

    # Docker should appear after the kubernetes section
    local section_line wrapper_line
    section_line=$(grep -n 'KUBERNETES' "$WRAPPERS_SCRIPT" | cut -d: -f1)
    wrapper_line=$(grep -n 'create_wrapper docker' "$WRAPPERS_SCRIPT" | cut -d: -f1)
    [[ "$wrapper_line" -gt "$section_line" ]]
}