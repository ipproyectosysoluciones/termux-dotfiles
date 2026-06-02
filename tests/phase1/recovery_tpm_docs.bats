#!/usr/bin/env bats
# Verify recovery.md documents explicit TPM git clone step

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "recovery.md has explicit TPM git clone step" {
    run grep -c "git clone.*tmux-plugins/tpm" "$PROJECT_ROOT/docs/recovery.md"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}

@test "recovery.md references TPM initialization" {
    run grep -c "install_plugins.sh\|tpm/scripts" "$PROJECT_ROOT/docs/recovery.md"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}