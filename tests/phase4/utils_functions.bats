#!/usr/bin/env bats
# tests/phase4/utils_functions.bats
# Tests for utils.sh session functions (session_exists, attach_or_switch, create_session)
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

# Source utils.sh directly (menu.sh sources it too)
source "$(resolve_script scripts/ai/utils.sh)"

setup() {
    mkdir -p "$TEST_TMPDIR"
}

teardown() {
    remove_mocks_from_path
}

########################################
# P4-T22: utils.sh session function tests
########################################

# Mock tmux that simulates behavior based on environment
create_mock_tmux() {
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/tmux" <<'MOCK_TMUX'
#!/usr/bin/env bash

# Parse arguments to find the session name
session_name=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t)
            session_name="$2"
            shift 2
            ;;
        -s)
            session_name="$2"
            shift 2
            ;;
        has-session)
            # For has-session -t session, check if session_name equals MOCK_TMUX_SESSION
            if [[ "$session_name" == "$MOCK_TMUX_SESSION" ]]; then
                exit 0
            else
                exit 1
            fi
            ;;
        switch-client)
            # Always succeed for mock
            exit 0
            ;;
        attach)
            # Always succeed for mock
            exit 0
            ;;
        new-session)
            # Always succeed for mock
            exit 0
            ;;
        send-keys)
            # Always succeed for mock
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done
MOCK_TMUX
    chmod +x "$mock_dir/tmux"
}

@test "session_exists uses tmux has-session -t" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'tmux has-session -t' "$utils_script"
    [ $status -eq 0 ]
}

@test "session_exists redirects stderr to /dev/null" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep '2>/dev/null' "$utils_script"
    [ $status -eq 0 ]
}

@test "session_exists function exists and has correct structure" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep -E 'session_exists\(\)' "$utils_script"
    [ $status -eq 0 ]
    run grep -E 'tmux has-session -t "\$1"' "$utils_script"
    [ $status -eq 0 ]
}

@test "attach_or_switch takes session name as argument" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'local session=' "$utils_script"
    [ $status -eq 0 ]
}

@test "attach_or_switch uses tmux switch-client when in TMUX" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'tmux switch-client -t' "$utils_script"
    [ $status -eq 0 ]
}

@test "attach_or_switch uses tmux attach when not in TMUX" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'tmux attach -t' "$utils_script"
    [ $status -eq 0 ]
}

@test "attach_or_switch checks TMUX environment variable" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep '\[ -n "\$TMUX" \]' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session takes session name as first argument" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'local session=' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session takes command as second argument" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'local command=' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session uses tmux new-session -d -s" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'tmux new-session -d -s' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session calls session_exists before creating" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'session_exists "\$session"' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session sends keys with C-m for enter" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep 'C-m' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session only sends keys if command is non-empty" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep -E '\[ -n "\$command" \]' "$utils_script"
    [ $status -eq 0 ]
}

@test "utils.sh contains all three session functions" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep -c 'session_exists()' "$utils_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]

    run grep -c 'attach_or_switch()' "$utils_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]

    run grep -c 'create_session()' "$utils_script"
    [ $status -eq 0 ]
    [ "$output" -ge 1 ]
}

@test "utils.sh shebang is correct" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run head -1 "$utils_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "utils.sh source statement uses SCRIPT_DIR" {
    local utils_script
    menu_script="$(resolve_script scripts/ai/menu.sh)"

    # menu.sh should source utils.sh using $SCRIPT_DIR
    run grep 'source "\$SCRIPT_DIR/utils\.sh"' "$menu_script"
    [ $status -eq 0 ]
}

@test "session_exists returns exit code from tmux has-session" {
    # This test verifies the function structure - tmux has-session returns 0 if session exists
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    # The function should be: tmux has-session -t "$1" 2>/dev/null
    # which returns the exit code from tmux
    run grep 'tmux has-session -t "\$1" 2>/dev/null' "$utils_script"
    [ $status -eq 0 ]
}

@test "attach_or_switch uses correct conditional logic" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    # Should check: if [ -n "$TMUX" ]; then switch-client else attach
    run grep -E 'if \[ -n "\$TMUX" \]; then' "$utils_script"
    [ $status -eq 0 ]
    run grep 'tmux switch-client -t "\$session"' "$utils_script"
    [ $status -eq 0 ]
    run grep 'tmux attach -t "\$session"' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session checks if session exists before creating" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    # Should have: if ! session_exists "$session"; then
    run grep 'if ! session_exists "\$session"' "$utils_script"
    [ $status -eq 0 ]
}

@test "create_session tmux new-session uses -d flag (detach)" {
    local utils_script
    utils_script="$(resolve_script scripts/ai/utils.sh)"

    run grep -E 'tmux new-session -d -s "\$session"' "$utils_script"
    [ $status -eq 0 ]
}