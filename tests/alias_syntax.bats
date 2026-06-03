#!/usr/bin/env bats

load test_helper

# Override PROJECT_ROOT: tests are at tests/ level (one level deep), not tests/subdir/
PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

@test "aliases.zsh contains ai-menu alias" {
    local aliases_file="$(resolve_script zsh/aliases.zsh)"
    run grep -E "^alias ai-menu=" "$aliases_file"
    [ "$status" -eq 0 ]
}

@test "aliases.zsh ai-menu alias points to menu.sh" {
    local aliases_file="$(resolve_script zsh/aliases.zsh)"
    run grep "alias ai-menu=" "$aliases_file"
    [ "$output" = "alias ai-menu=\"\$HOME/dotfiles/scripts/ai/menu.sh\"" ]
}

@test "aliases.zsh existing ai alias unchanged" {
    local aliases_file="$(resolve_script zsh/aliases.zsh)"
    run grep -E "^alias ai=" "$aliases_file"
    [ "$status" -eq 0 ]
}

@test "aliases.zsh passes basic alias syntax check" {
    local aliases_file="$(resolve_script zsh/aliases.zsh)"
    local bash_bin="$(command -v bash)"
    if [ -z "$bash_bin" ]; then
        skip "bash not found in PATH"
    fi
    run "$bash_bin" -n "$aliases_file"
    [ "$status" -eq 0 ]
}