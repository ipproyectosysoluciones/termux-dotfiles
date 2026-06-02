#!/usr/bin/env bats
# tests/phase3/bootstrap_mistral.bats
# Verify ai.sh contains mistral installation step

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "ai.sh contains mistral installation step" {
    grep -qi "mistral" "$PROJECT_ROOT/scripts/debian/bootstrap/ai.sh"
}