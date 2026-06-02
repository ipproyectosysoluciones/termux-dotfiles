#!/usr/bin/env bats
# tests/phase3/provider_selector_mistral.bats
# Verify provider_selector.sh contains mistral routing

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "provider_selector.sh contains mistral routing" {
    grep -qi "mistral" "$PROJECT_ROOT/scripts/ai/core/provider_selector.sh"
}