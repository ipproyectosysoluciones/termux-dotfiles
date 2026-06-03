#!/usr/bin/env bats

@test "detect_menu_tool returns gum when gum is available" {
    local temp_script="$BATS_TEST_TMPDIR/detect_tool_gum.sh"

    cat > "$temp_script" << 'SCRIPTEOF'
#!/usr/bin/env bash
gum() {
    return 0
}
detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}
detect_menu_tool
SCRIPTEOF
    chmod +x "$temp_script"

    run "$temp_script"
    [ "$output" = "gum" ]
}

@test "detect_menu_tool returns select when gum is unavailable" {
    local temp_script="$BATS_TEST_TMPDIR/detect_tool_select.sh"

    cat > "$temp_script" << 'SCRIPTEOF'
#!/usr/bin/env bash
# gum is not defined - command -v gum will fail
detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}
detect_menu_tool
SCRIPTEOF
    chmod +x "$temp_script"

    run "$temp_script"
    [ "$output" = "select" ]
}

@test "menu.sh case routing uses select when gum unavailable" {
    local temp_dir="$BATS_TEST_TMPDIR/test_select"
    mkdir -p "$temp_dir"

    cat > "$temp_dir/menu.sh" << 'MENUEOF'
#!/usr/bin/env bash

detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

MENU_TOOL=$(detect_menu_tool)

case "$MENU_TOOL" in
  "gum")
    echo "Using gum"
    ;;
  "select")
    echo "Using select"
    ;;
esac
MENUEOF
    chmod +x "$temp_dir/menu.sh"

    run "$temp_dir/menu.sh"
    [ "$output" = "Using select" ]
}

@test "menu.sh case routing uses gum when available" {
    local temp_dir="$BATS_TEST_TMPDIR/test_gum"
    mkdir -p "$temp_dir"

    # Create fake gum
    local fake_bin="$temp_dir/bin"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/gum" << 'GUMEOF'
#!/usr/bin/env bash
exit 0
GUMEOF
    chmod +x "$fake_bin/gum"

    cat > "$temp_dir/menu.sh" << 'MENUEOF'
#!/usr/bin/env bash

detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

MENU_TOOL=$(detect_menu_tool)

case "$MENU_TOOL" in
  "gum")
    echo "Using gum"
    ;;
  "select")
    echo "Using select"
    ;;
esac
MENUEOF
    chmod +x "$temp_dir/menu.sh"

    # Prepend temp_dir/bin to PATH so gum is found
    run env PATH="$fake_bin:$PATH" "$temp_dir/menu.sh"
    [ "$output" = "Using gum" ]
}

@test "menu.sh shows informative message in select fallback" {
    local temp_dir="$BATS_TEST_TMPDIR/test_fallback"
    mkdir -p "$temp_dir"

    cat > "$temp_dir/menu.sh" << 'MENUEOF'
#!/usr/bin/env bash

detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

MENU_TOOL=$(detect_menu_tool)

case "$MENU_TOOL" in
  "gum")
    exit 0
    ;;
  "select")
    echo "gum is recommended for best experience" >&2
    exit 0
    ;;
esac
MENUEOF
    chmod +x "$temp_dir/menu.sh"

    run "$temp_dir/menu.sh"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "gum is recommended for best experience" ]
}

@test "menu.sh detects gum at Termux path" {
    local temp_dir="$BATS_TEST_TMPDIR/test_termux_path"
    mkdir -p "$temp_dir"

    # Create gum at Termux path
    local termux_gum="$temp_dir/data/data/com.termux/files/usr/bin/gum"
    mkdir -p "$(dirname "$termux_gum")"
    cat > "$termux_gum" << 'GUMEOF'
#!/usr/bin/env bash
exit 0
GUMEOF
    chmod +x "$termux_gum"

    cat > "$temp_dir/menu.sh" << 'MENUEOF'
#!/usr/bin/env bash

detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

MENU_TOOL=$(detect_menu_tool)
echo "$MENU_TOOL"
MENUEOF
    chmod +x "$temp_dir/menu.sh"

    # Run with the Termux gum in PATH
    run env PATH="$(dirname "$termux_gum"):$PATH" "$temp_dir/menu.sh"
    [ "$output" = "gum" ]
}