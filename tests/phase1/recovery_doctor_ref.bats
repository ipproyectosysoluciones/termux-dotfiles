#!/usr/bin/env bats
# Verify recovery.md references doctor.sh

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "recovery.md references doctor.sh" {
    run grep -c "doctor.sh" "$PROJECT_ROOT/docs/recovery.md"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}