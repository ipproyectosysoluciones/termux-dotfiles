#!/usr/bin/env bats
# tests/phase3/mistral_executable.bats
# Verify mistral.sh is executable

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "mistral.sh is executable" {
    [ -x "$PROJECT_ROOT/scripts/ai/providers/mistral.sh" ]
}