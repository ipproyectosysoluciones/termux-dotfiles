#!/usr/bin/env bats
# tests/phase3/mistral_env_var.bats
# Verify mistral.sh references MISTRAL_API_KEY

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "mistral.sh references MISTRAL_API_KEY" {
    grep -q "MISTRAL_API_KEY" "$PROJECT_ROOT/scripts/ai/providers/mistral.sh"
}