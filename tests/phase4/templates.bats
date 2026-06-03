#!/usr/bin/env bats
# tests/phase4/templates.bats
# Tests for template build_layout functions (default, mobile, node, remote)
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

setup() {
    mkdir -p "$TEST_TMPDIR"
}

teardown() {
    remove_mocks_from_path
}

########################################
# P4-T24: template build_layout tests
########################################

# Mock tmux for testing
create_mock_tmux() {
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/tmux" <<'MOCK_TMUX'
#!/usr/bin/env bash

case "$1" in
    rename-window)
        echo "[mock-tmux] renamed window: $2 $3"
        exit 0
        ;;
    new-window)
        shift
        local name=""
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -t) shift ;;
                -n) name="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        echo "[mock-tmux] created window: $name"
        exit 0
        ;;
    send-keys)
        echo "[mock-tmux] sent keys"
        exit 0
        ;;
    select-window)
        echo "[mock-tmux] selected window"
        exit 0
        ;;
    list-windows)
        echo "0"
        exit 0
        ;;
    *)
        echo "[mock-tmux] command: $1"
        exit 0
        ;;
esac
MOCK_TMUX
    chmod +x "$mock_dir/tmux"
}

@test "default.sh template exists and defines build_layout" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep -c 'build_layout()' "$template_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "default.sh shebang is correct" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run head -1 "$template_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "default.sh build_layout takes session argument" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'local session=' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh renames first window to 'shell'" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'tmux rename-window.*"shell"' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh creates editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'tmux new-window' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh opens nvim in editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'nvim' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh opens claude in claude window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'claude' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh opens gemini in gemini window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'gemini' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh selects editor window at end" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep -c 'select-window' "$template_script"
    [ $status -eq 0 ]
    run grep '\$session:editor' "$template_script"
    [ $status -eq 0 ]
}

@test "default.sh uses C-m for enter key" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/default.sh)"

    run grep 'C-m' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh template exists and defines build_layout" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep -c 'build_layout()' "$template_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "mobile.sh shebang is correct" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run head -1 "$template_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "mobile.sh build_layout takes session argument" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep 'local session=' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh has sleep for tmux stabilization" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep 'sleep 0.3' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh gets current window with list-windows" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep 'tmux list-windows' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh renames window to 'editor'" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep -c '"editor"' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh creates claude window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep -c 'new-window' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh opens claude in claude window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep -c '"claude" C-m' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh selects editor window at end" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep -c 'select-window' "$template_script"
    [ $status -eq 0 ]
}

@test "mobile.sh opens nvim in editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/mobile.sh)"

    run grep 'nvim' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh template exists and defines build_layout" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep -c 'build_layout()' "$template_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "node.sh shebang is correct" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run head -1 "$template_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "node.sh build_layout takes session argument" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep 'local session=' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh renames first window to 'server'" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep 'tmux rename-window.*"server"' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh opens pnpm dev in server window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep 'pnpm dev' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh creates editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep 'tmux new-window' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh opens nvim in editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep -c '"nvim" C-m' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh creates claude window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep -c 'new-window' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh creates gemini window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep -c '"gemini" C-m' "$template_script"
    [ $status -eq 0 ]
}

@test "node.sh selects editor window at end" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/node.sh)"

    run grep -c 'select-window' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh template exists and defines build_layout" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep -c 'build_layout()' "$template_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "remote.sh shebang is correct" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run head -1 "$template_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "remote.sh build_layout takes session argument" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep 'local session=' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh renames first window to 'shell'" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep 'tmux rename-window.*"shell"' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh creates editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep 'tmux new-window' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh opens nvim in editor window" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep -c '"nvim" C-m' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh selects editor window at end" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    run grep -c 'select-window' "$template_script"
    [ $status -eq 0 ]
}

@test "remote.sh has minimal layout (2 windows only)" {
    local template_script
    template_script="$(resolve_script scripts/ai/templates/remote.sh)"

    # Count new-window calls: should be exactly 1 (only editor, shell is already there)
    run grep -c 'tmux new-window' "$template_script"
    [ $status -eq 0 ]
    [ "$output" -eq 1 ]
}

@test "all templates use tmux send-keys with C-m" {
    run grep -c 'C-m' "$(resolve_script scripts/ai/templates/default.sh)"
    [ $status -eq 0 ]
    run grep -c 'C-m' "$(resolve_script scripts/ai/templates/mobile.sh)"
    [ $status -eq 0 ]
    run grep -c 'C-m' "$(resolve_script scripts/ai/templates/node.sh)"
    [ $status -eq 0 ]
    run grep -c 'C-m' "$(resolve_script scripts/ai/templates/remote.sh)"
    [ $status -eq 0 ]
}

@test "all templates use session variable in tmux commands" {
    run grep -c '\$session' "$(resolve_script scripts/ai/templates/default.sh)"
    [ $status -eq 0 ]
    run grep -c '\$session' "$(resolve_script scripts/ai/templates/mobile.sh)"
    [ $status -eq 0 ]
    run grep -c '\$session' "$(resolve_script scripts/ai/templates/node.sh)"
    [ $status -eq 0 ]
    run grep -c '\$session' "$(resolve_script scripts/ai/templates/remote.sh)"
    [ $status -eq 0 ]
}

@test "build_layout function signature is consistent across templates" {
    run grep -c 'build_layout()' "$(resolve_script scripts/ai/templates/default.sh)"
    [ $status -eq 0 ]
    run grep -c 'build_layout()' "$(resolve_script scripts/ai/templates/mobile.sh)"
    [ $status -eq 0 ]
    run grep -c 'build_layout()' "$(resolve_script scripts/ai/templates/node.sh)"
    [ $status -eq 0 ]
    run grep -c 'build_layout()' "$(resolve_script scripts/ai/templates/remote.sh)"
    [ $status -eq 0 ]
}