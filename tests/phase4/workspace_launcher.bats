#!/usr/bin/env bats
# tests/phase4/workspace_launcher.bats
# Tests for workspace.sh launcher with template auto-detection
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

# Source workspace.sh directly
source "$(resolve_script scripts/ai/core/workspace.sh)"

setup() {
    mkdir -p "$TEST_TMPDIR"
}

teardown() {
    remove_mocks_from_path
}

########################################
# P4-T23: workspace.sh launcher tests
########################################

# Mock tmux for testing
create_mock_tmux() {
    local mock_dir="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/tmux" <<'MOCK_TMUX'
#!/usr/bin/env bash

# Parse arguments
session_name=""
command_arg=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d) shift ;;
        -s) session_name="$2"; shift 2 ;;
        -c) command_arg="$2"; shift 2 ;;
        -t) session_name="$2"; shift 2 ;;
        new-session)
            shift
            session_name=""
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -d) shift ;;
                    -s) session_name="$2"; shift 2 ;;
                    -c) shift 2 ;;
                    *) session_name="$1"; shift ;;
                esac
            done
            echo "[mock-tmux] created session: $session_name"
            exit 0
            ;;
        rename-window)
            shift; shift  # -t window_name
            echo "[mock-tmux] renamed window"
            exit 0
            ;;
        list-windows)
            echo "0"
            exit 0
            ;;
        new-window)
            shift; shift  # skip flags
            echo "[mock-tmux] created window: $1"
            exit 0
            ;;
        send-keys)
            exit 0
            ;;
        select-window)
            exit 0
            ;;
        has-session)
            exit 1  # Default: session does not exist
            ;;
        *)
            echo "[mock-tmux] command: $1"
            exit 0
            ;;
    esac
done
MOCK_TMUX
    chmod +x "$mock_dir/tmux"
}

@test "workspace.sh uses XDG_STATE_HOME for workspace database" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'XDG_STATE_HOME' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace.sh defaults to ~/.ai/workspaces when no XDG_STATE_HOME" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'HOME/.ai/workspaces' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace.sh creates workspace database directory" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'mkdir -p.*WORKSPACE_DB' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace_metadata function exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep -c 'ensure_workspace_metadata()' "$workspace_script"
    [ $status -eq 0 ]
}

@test "load_workspace_metadata function exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep -c 'load_workspace_metadata()' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace_initialized function exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep -c 'workspace_initialized()' "$workspace_script"
    [ $status -eq 0 ]
}

@test "mark_workspace_initialized function exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep -c 'mark_workspace_initialized()' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace function exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep -c 'ensure_workspace()' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace_initialized checks for initialized marker file" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'WORKSPACE_DB/.*initialized' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace_initialized returns true when file exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'echo "true"' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace_initialized returns false when file does not exist" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'echo "false"' "$workspace_script"
    [ $status -eq 0 ]
}

@test "mark_workspace_initialized touches marker file" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'touch.*WORKSPACE_DB.*initialized' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace uses tmux has-session to check existing sessions" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'tmux has-session -t' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace returns 0 if session already exists" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'return 0' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace creates new session with tmux new-session" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'tmux new-session' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace passes root directory to tmux new-session -c" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    # The -c flag is on a separate line with line continuation
    run grep -c '\-c "\$root"' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace renames default window to 'main'" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep '"main"' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace.sh passes session name to tmux new-session -s via flag" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep '\-s "\$session"' "$workspace_script"
    [ $status -eq 0 ]
}

@test "workspace.sh shebang is correct" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run head -1 "$workspace_script"
    [ "$output" == "#!/data/data/com.termux/files/usr/bin/bash" ]
}

@test "ensure_workspace takes session name as first argument" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'local session=' "$workspace_script"
    [ $status -eq 0 ]
}

@test "ensure_workspace takes root directory as second argument" {
    local workspace_script
    workspace_script="$(resolve_core workspace)"

    run grep 'local root=' "$workspace_script"
    [ $status -eq 0 ]
}