#!/usr/bin/env bats
# Verify installation.md references ai.sh bootstrap script

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "installation.md references scripts/debian/bootstrap/ai.sh" {
    run grep -c "scripts/debian/bootstrap/ai.sh\|ai\.sh" "$PROJECT_ROOT/docs/installation.md"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}