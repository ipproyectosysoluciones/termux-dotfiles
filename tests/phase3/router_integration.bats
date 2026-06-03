#!/usr/bin/env bats
# Test for BUG-FIX-2: dynamic path resolution in router.sh
# RED phase: Write failing test asserting BASE_DIR uses BASH_SOURCE[0]

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

teardown() {
    # Cleanup if needed
    true
}

@test "router.sh uses BASH_SOURCE[0] for SCRIPT_DIR detection" {
    # Read the SCRIPT_DIR assignment line
    run grep 'SCRIPT_DIR=' "$PROJECT_ROOT/scripts/ai/core/router.sh"
    echo "SCRIPT_DIR line: $output"

    # SCRIPT_DIR should use BASH_SOURCE[0]
    [[ "$output" == *'BASH_SOURCE'* ]]
    [[ "$output" == *'dirname'* ]]
}

@test "router.sh uses BASE_DIR derived from SCRIPT_DIR" {
    # Read the BASE_DIR assignment line
    run grep 'BASE_DIR=' "$PROJECT_ROOT/scripts/ai/core/router.sh"
    echo "BASE_DIR line: $output"

    # BASE_DIR should be derived from SCRIPT_DIR, not hardcoded
    [[ "$output" == *'SCRIPT_DIR'* ]]

    # BASE_DIR should NOT be hardcoded to $HOME/dotfiles
    [[ "$output" != *'$HOME/dotfiles'* ]]
}

@test "router.sh sources use relative BASE_DIR path" {
    # Read the source commands
    run grep "^source" "$PROJECT_ROOT/scripts/ai/core/router.sh"
    echo "Source lines: $output"

    # All source lines should use $BASE_DIR (dynamic) not hardcoded $HOME/dotfiles
    # The current bug would be: source "$HOME/dotfiles/scripts/ai/providers/..."
    # The fix should be: source "$BASE_DIR/providers/..."
    [[ "$output" != *'$HOME/dotfiles'* ]]

    # Should use BASE_DIR for relative path
    [[ "$output" == *'$BASE_DIR'* ]]
}

@test "router.sh provider sources are relative to script location" {
    # Verify the sourcing paths work from any CWD
    # When SCRIPT_DIR is computed via BASH_SOURCE[0], BASE_DIR/providers/*.sh
    # should resolve correctly

    # Check that all provider source lines use $BASE_DIR
    local provider_sources=$(grep "^source" "$PROJECT_ROOT/scripts/ai/core/router.sh")
    echo "Provider sources: $provider_sources"

    # All should use $BASE_DIR, not literal paths
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            [[ "$line" == *'$BASE_DIR'* ]] || [[ "$line" != *'$HOME'* ]]
        fi
    done <<< "$provider_sources"
}