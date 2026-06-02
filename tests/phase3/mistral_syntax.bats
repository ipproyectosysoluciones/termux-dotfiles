#!/usr/bin/env bats
# tests/phase3/mistral_syntax.bats
# Verify mistral.sh has valid bash syntax

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "mistral.sh has valid bash syntax" {
    run bash -n "$PROJECT_ROOT/scripts/ai/providers/mistral.sh"
    [ "$status" -eq 0 ]
}