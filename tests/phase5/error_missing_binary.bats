#!/usr/bin/env bats
# Test for BUG-FIX-1: dynamic path resolution in bootstrap/ai.sh
# RED phase: Write failing test asserting ROOT uses BASH_SOURCE[0]

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

teardown() {
    # Cleanup if needed
    true
}

@test "bootstrap/ai.sh ROOT uses BASH_SOURCE[0] for dynamic path" {
    # Read the ROOT assignment line
    run grep '^ROOT=' "$PROJECT_ROOT/scripts/debian/bootstrap/ai.sh"
    echo "ROOT line: $output"

    # The ROOT assignment should use BASH_SOURCE[0], not hardcoded $HOME/dotfiles
    # Current bug: ROOT="$HOME/dotfiles/scripts/debian"
    # Expected fix: ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Assert ROOT uses BASH_SOURCE pattern
    [[ "$output" == *'BASH_SOURCE'* ]]

    # Assert ROOT does NOT use hardcoded $HOME/dotfiles
    [[ "$output" != *'$HOME/dotfiles'* ]]
}

@test "bootstrap/ai.sh ROOT is derived from script location" {
    # When script is sourced, ROOT should resolve relative to script's directory
    # not to a hardcoded path that assumes specific installation location

    # Check that ROOT line contains dirname and BASH_SOURCE
    run grep '^ROOT=' "$PROJECT_ROOT/scripts/debian/bootstrap/ai.sh"

    # Must use dirname to compute path
    [[ "$output" == *'dirname'* ]]

    # Must use BASH_SOURCE[0] to get script's own location
    [[ "$output" == *'BASH_SOURCE'* ]]
}