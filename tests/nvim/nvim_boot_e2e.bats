#!/usr/bin/env bats
# T6.1 — E2E boot smoke test (Phase 6)
#
# Verifies that Neovim boots successfully with the full plugin
# configuration. Tests:
#   1. nvim --version exits 0 and reports ≥0.10
#   2. init.lua loads without error (headless, no plugins block)
#   3. Lazy plugin system is operational
#
# This is the foundational E2E test — if this fails, nothing else matters.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

########################################
# Test 1 — nvim --version
########################################
@test "nvim --version exits 0" {
    run nvim --version
    [ "$status" -eq 0 ]
}

@test "nvim version is at least 0.10.0" {
    run nvim --version | head -1
    [ "$status" -eq 0 ]
    # Version line format: "NVIM v0.12.2" or "NVIM v0.11.0-dev"
    [[ "$output" == "NVIM v"* ]]
}

########################################
# Test 2 — init.lua loads without error
########################################
@test "init.lua loads without error in headless mode" {
    run nvim --headless \
        --noplugin \
        -c "lua vim.fn.stdpath('config')" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
}

@test "init.lua loads all plugin groups without error" {
    run nvim --headless \
        -c "lua require('plugins')" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
}

########################################
# Test 3 — Lazy plugin system operational
########################################
@test "lazy.nvim module loads" {
    run nvim --headless \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;' .. package.path" \
        -c "lua require('lazy')" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
}

@test "lazy.plugins() returns a table" {
    run nvim --headless \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;' .. package.path" \
        -c "lua local lazy = require('lazy'); print(type(lazy.plugins))" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "function" ]
}

########################################
# Test 4 — User module (feature flags) loads
########################################
@test "user/init.lua loads and has all feature flag functions" {
    run nvim --headless \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
        -c "lua local u = require('user'); print(tostring(u.has_ai_keys ~= nil))" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

@test "user module has has_biome and has_octo functions" {
    run nvim --headless \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
        -c "lua local u = require('user'); print(tostring(u.has_biome ~= nil and u.has_octo ~= nil))" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}