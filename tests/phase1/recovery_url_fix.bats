#!/usr/bin/env bats
# Verify recovery.md has no old repo URL

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "recovery.md does not contain old repo URL" {
    run grep -c "ipproyectosysoluciones" "$PROJECT_ROOT/docs/recovery.md"
    [ "$status" -eq 1 ]
}