#!/usr/bin/env bats
# tests/phase4/menu_interaction.bats
# Tests for menu.sh choice routing and SCRIPT_DIR usage (BUG-FIX-3 verification)
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

setup() {
    mkdir -p "$TEST_TMPDIR"
}

teardown() {
    remove_mocks_from_path
}

########################################
# P4-T21: menu.sh interaction tests
########################################

@test "menu.sh defines SCRIPT_DIR correctly (BUG-FIX-3 verification)" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE\[0\]}"' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh sources utils.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep 'source.*utils\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh has case statement for CHOICE" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -c 'case "$CHOICE" in' "$menu_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "menu.sh case statement routes NeoVim to nvim.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"NeoVim"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/nvim\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement routes OpenCode to opencode.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"OpenCode"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/opencode\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement routes Gentle AI to gentle.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"Gentle AI"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/gentle\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement routes Engram to engram.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"Engram"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/engram\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement routes Full Workspace to workspace.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"Full Workspace"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/workspace\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement routes Sessions to sessions.sh" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -E '"Sessions"\)' "$menu_script"
    [ $status -eq 0 ]
    run grep -E '\$\SCRIPT_DIR/sessions\.sh' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh case statement exits on Exit choice" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -c 'exit 0' "$menu_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
    # Verify Exit case has exit 0
    awk '/"Exit"\)/{getline; if(/exit 0/) found=1} END{exit !found}' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh has clear before banner" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep -c '^clear$' "$menu_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "menu.sh calls banner with AI Workspace Launcher" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep 'banner "AI Workspace Launcher"' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh uses gum choose for menu display" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep 'gum choose' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh CHOICE captures gum choose output" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    run grep 'CHOICE=$(gum choose' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh has all expected menu options" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    # Check for each expected option
    run grep '"NeoVim"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"OpenCode"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"Gentle AI"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"Engram"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"Full Workspace"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"Sessions"' "$menu_script"
    [ $status -eq 0 ]
    run grep '"Exit"' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh uses \$SCRIPT_DIR for all script invocations (BUG-FIX-3)" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    # All invocations should use $SCRIPT_DIR/ not hardcoded paths
    run grep -E '\$SCRIPT_DIR/' "$menu_script"
    [ $status -eq 0 ]
}

@test "menu.sh has no hardcoded absolute paths (BUG-FIX-3)" {
    local menu_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"
    # Verify no hardcoded paths like /data/data/... or absolute paths
    run grep -E '^[^#]*"/data/data/com.termux' "$menu_script"
    [ $status -ne 0 ]
}