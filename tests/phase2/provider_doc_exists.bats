#!/usr/bin/env bats
# Verify provider-architecture.md exists

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "provider-architecture.md exists" {
    [ -f "$PROJECT_ROOT/docs/provider-architecture.md" ]
}
