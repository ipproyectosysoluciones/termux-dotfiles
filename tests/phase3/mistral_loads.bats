#!/usr/bin/env bats
# tests/phase3/mistral_loads.bats
# Verify mistral.sh sources without errors

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "mistral.sh sources without errors" {
    run bash -c "source $PROJECT_ROOT/scripts/ai/providers/mistral.sh"
    [ "$status" -eq 0 ]
}