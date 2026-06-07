#!/usr/bin/env bats
# Extract script paths from recovery.md and verify each exists

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "recovery.md referenced scripts exist" {
    # Extract script paths referenced in recovery.md
    local script_paths=(
        "scripts/install.sh"
        "scripts/core/symlinks.sh"
        "scripts/nvim/zsh-plugins.sh"
    )

    for script_path in "${script_paths[@]}"; do
        if [[ -f "$PROJECT_ROOT/$script_path" ]]; then
            echo "$script_path exists"
        else
            echo "$script_path does NOT exist"
            return 1
        fi
    done
}

@test "recovery.md TPM path referenced" {
    run grep -c "tmux-plugins/tpm" "$PROJECT_ROOT/docs/recovery.md"
    [ "$status" -eq 0 ]
    [ "$output" -gt 0 ]
}