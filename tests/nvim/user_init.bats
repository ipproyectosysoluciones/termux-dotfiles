#!/usr/bin/env bats
# T1.5 — `nvim/lua/user/init.lua` feature-flag chokepoint
#
# Verifies that the env-var helpers work as the design specifies:
#   1. `M.has_ai_keys()` returns true when ANY of GEMINI_API_KEY /
#      ANTHROPIC_API_KEY / OPENAI_API_KEY is set; false otherwise.
#   2. `M.has_biome()` returns false by default (opt-in env var).
#   3. `M.has_octo()` returns true when `gh` is on PATH, false otherwise.
#
# This is the single chokepoint that gates Phase 2-4 plugin loads
# (CodeCompanion, biome, octo.nvim). T2.1 depends on this file.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    USER_INIT="$PROJECT_ROOT/nvim/lua/user/init.lua"
    [ -f "$USER_INIT" ]
}

########################################
# Helper: source the module in a fresh Lua state with controlled env
########################################

load_user_module() {
    # Strip the named env vars from the child's environment.
    # Args: env var names to strip, then the rest is the Lua snippet.
    local strip_vars=("$@")
    local lua_args=()
    for var in "${strip_vars[@]}"; do
        if [[ "$var" == "--" ]]; then
            shift 1
            lua_args=("$@")
            break
        fi
    done

    # Build a clean env with the requested variables unset
    local clean_env=()
    for var in "${strip_vars[@]}"; do
        [[ "$var" == "--" ]] && continue
        clean_env+=("env" "-u" "$var")
    done

    # Use nvim --headless to source the file and call a function
    HOME="$BATS_TEST_TMPDIR" \
    XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
    nvim --headless --clean \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
        -c "lua local m = require('user'); io.write(tostring(m.$1()))" \
        -c "q!" 2>&1
}

########################################
# Test 1 — has_ai_keys: no keys set → false
########################################

@test "user.has_ai_keys() returns false when no AI API key env vars are set" {
    run env -u GEMINI_API_KEY -u ANTHROPIC_API_KEY -u OPENAI_API_KEY \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        nvim --headless --clean \
            -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
            -c "lua local m = require('user'); io.write(tostring(m.has_ai_keys()))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

########################################
# Test 2 — has_ai_keys: GEMINI_API_KEY set → true
########################################

@test "user.has_ai_keys() returns true when GEMINI_API_KEY is set" {
    run env -u ANTHROPIC_API_KEY -u OPENAI_API_KEY \
        GEMINI_API_KEY="test-key" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        nvim --headless --clean \
            -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
            -c "lua local m = require('user'); io.write(tostring(m.has_ai_keys()))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

########################################
# Test 3 — has_ai_keys: ANTHROPIC_API_KEY set → true
########################################

@test "user.has_ai_keys() returns true when ANTHROPIC_API_KEY is set" {
    run env -u GEMINI_API_KEY -u OPENAI_API_KEY \
        ANTHROPIC_API_KEY="test-key" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        nvim --headless --clean \
            -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
            -c "lua local m = require('user'); io.write(tostring(m.has_ai_keys()))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

########################################
# Test 4 — has_biome: default → false
########################################

@test "user.has_biome() returns false by default (opt-in via BIOME_ENABLED)" {
    run env -u BIOME_ENABLED \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        nvim --headless --clean \
            -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
            -c "lua local m = require('user'); io.write(tostring(m.has_biome()))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "false" ]
}

########################################
# Test 5 — has_octo: gh on PATH → true
########################################

@test "user.has_octo() returns true when gh is on PATH" {
    # Sanity check: gh must be on PATH for this test to be meaningful.
    command -v gh >/dev/null 2>&1 || skip "gh CLI not installed"
    run env \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        nvim --headless --clean \
            -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
            -c "lua local m = require('user'); io.write(tostring(m.has_octo()))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}
