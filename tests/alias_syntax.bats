#!/usr/bin/env bats

@test "aliases.zsh contains ai-menu alias" {
    local aliases_file="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth/zsh/aliases.zsh"
    run grep -E "^alias ai-menu=" "$aliases_file"
    [ "$status" -eq 0 ]
}

@test "aliases.zsh ai-menu alias points to menu.sh" {
    local aliases_file="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth/zsh/aliases.zsh"
    run grep "alias ai-menu=" "$aliases_file"
    [ "$output" = "alias ai-menu=\"\$HOME/dotfiles/scripts/ai/menu.sh\"" ]
}

@test "aliases.zsh existing ai alias unchanged" {
    local aliases_file="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth/zsh/aliases.zsh"
    run grep -E "^alias ai=" "$aliases_file"
    [ "$status" -eq 0 ]
}

@test "aliases.zsh passes basic alias syntax check" {
    local aliases_file="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth/zsh/aliases.zsh"
    # Check that the file can be sourced without errors
    run /usr/bin/bash -n "$aliases_file"
    [ "$status" -eq 0 ]
}