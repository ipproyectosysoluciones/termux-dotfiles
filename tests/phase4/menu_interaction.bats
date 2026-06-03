#!/usr/bin/env bats
# Test for BUG-FIX-3: dynamic path resolution in menu.sh
# Verifies SCRIPT_DIR is used for self-location and sibling script invocation

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

teardown() {
    # Cleanup if needed
    true
}

@test "menu.sh uses BASH_SOURCE[0] for SCRIPT_DIR detection" {
    # Read the SCRIPT_DIR assignment line
    run grep 'SCRIPT_DIR=' "$PROJECT_ROOT/scripts/ai/menu.sh"
    echo "SCRIPT_DIR line: $output"

    # SCRIPT_DIR should use BASH_SOURCE[0]
    [[ "$output" == *'BASH_SOURCE'* ]]
    [[ "$output" == *'dirname'* ]]
}

@test "menu.sh sources use SCRIPT_DIR for relative paths" {
    # Read the source commands
    run grep "^source" "$PROJECT_ROOT/scripts/ai/menu.sh"
    echo "Source lines: $output"

    # All source lines should use $SCRIPT_DIR (dynamic) not hardcoded paths
    # The current bug would be: source "$HOME/dotfiles/scripts/ai/utils.sh"
    # The fix should be: source "$SCRIPT_DIR/utils.sh"
    [[ "$output" == *'$SCRIPT_DIR'* ]]
}

@test "menu.sh script invocations use SCRIPT_DIR for sibling scripts" {
    # Read the case statement body lines that invoke scripts
    # Looking for lines like: "$SCRIPT_DIR/nvim.sh"
    run grep '\$SCRIPT_DIR/' "$PROJECT_ROOT/scripts/ai/menu.sh"
    echo "SCRIPT_DIR invocations: $output"

    # All script invocations should use $SCRIPT_DIR for relative path
    [[ "$output" == *'$SCRIPT_DIR'* ]]

    # Verify no hardcoded script paths like ~/dotfiles/scripts/ai/...
    run grep '~/dotfiles' "$PROJECT_ROOT/scripts/ai/menu.sh"
    [ "$status" -eq 1 ]
}

@test "menu.sh does not contain hardcoded \$HOME/dotfiles paths" {
    # Verify the script doesn't use hardcoded paths
    run grep '$HOME/dotfiles' "$PROJECT_ROOT/scripts/ai/menu.sh"
    echo "Hardcoded paths found: $output"

    # Should not find any hardcoded $HOME/dotfiles
    # Note: run exits with status 1 when grep finds nothing - that's success here
    [ "$status" -eq 1 ] || [[ "$output" != *'$HOME/dotfiles'* ]]
}