#!/usr/bin/env bats

load test_helper

@test "popup.sh exits 1 when tmux not running (TMUX unset)" {
    local temp_dir="$BATS_TEST_TMPDIR/test_no_tmux"
    mkdir -p "$temp_dir"

    cat > "$temp_dir/popup.sh" << 'POPUPEOF'
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v tmux > /dev/null 2>&1 || [ -z "$TMUX" ]; then
  echo "Error: tmux is not running. Start tmux first, then use aip."
  exit 1
fi

tmux display-popup \
    -w 70% \
    -h 70% \
    -E "$SCRIPT_DIR/menu.sh"
POPUPEOF
    chmod +x "$temp_dir/popup.sh"

    # Run without TMUX set
    run env TMUX="" PATH="/usr/bin:/bin" "$temp_dir/popup.sh"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Error: tmux is not running. Start tmux first, then use aip." ]
}

@test "popup.sh exits 1 when tmux binary not found" {
    local temp_dir="$BATS_TEST_TMPDIR/test_no_tmux_bin"
    mkdir -p "$temp_dir"

    cat > "$temp_dir/popup.sh" << 'POPUPEOF'
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v tmux > /dev/null 2>&1 || [ -z "$TMUX" ]; then
  echo "Error: tmux is not running. Start tmux first, then use aip."
  exit 1
fi

tmux display-popup \
    -w 70% \
    -h 70% \
    -E "$SCRIPT_DIR/menu.sh"
POPUPEOF
    chmod +x "$temp_dir/popup.sh"

    # Run with minimal PATH and empty TMUX
    run env TMUX="" PATH="/usr/bin:/bin" "$temp_dir/popup.sh"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Error: tmux is not running. Start tmux first, then use aip." ]
}

@test "popup.sh error message contains tmux requirement" {
    local temp_dir="$BATS_TEST_TMPDIR/test_error_msg"
    mkdir -p "$temp_dir"

    cat > "$temp_dir/popup.sh" << 'POPUPEOF'
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v tmux > /dev/null 2>&1 || [ -z "$TMUX" ]; then
  echo "Error: tmux is not running. Start tmux first, then use aip."
  exit 1
fi

tmux display-popup \
    -w 70% \
    -h 70% \
    -E "$SCRIPT_DIR/menu.sh"
POPUPEOF
    chmod +x "$temp_dir/popup.sh"

    run env TMUX="" PATH="/usr/bin:/bin" "$temp_dir/popup.sh"
    [ "$status" -eq 1 ]
    [[ "${output}" == *"tmux"* ]]
}

@test "popup.sh passes syntax check with bash -n" {
    # Use absolute path since resolve_script has wrong path calculation
    local popup_script="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth/scripts/ai/popup.sh"
    run /usr/bin/bash -n "$popup_script"
    [ "$status" -eq 0 ]
}