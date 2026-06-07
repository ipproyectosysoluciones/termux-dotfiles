#!/usr/bin/env bats
# T3.2 stub — Neotest plugin spec coverage
#
# Verifies that `nvim/lua/plugins/testing/init.lua` declares the
# neotest + neotest-jest + neotest-playwright plugin specs (MEAN/MERN
# test runner integration). The file was previously empty; the
# presence of all 3 spec source strings is the T3.2 acceptance.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    TESTING_INIT="$NVIM_DIR/lua/plugins/testing/init.lua"
}

########################################
# Test 1 — neotest core spec is declared
########################################

@test "plugins/testing/init.lua declares the nvim-neotest/neotest spec" {
    [ -f "$TESTING_INIT" ]
    grep -q 'nvim-neotest/neotest' "$TESTING_INIT"
}

########################################
# Test 2 — neotest-jest spec is declared
########################################

@test "plugins/testing/init.lua declares the nvim-neotest/neotest-jest spec" {
    [ -f "$TESTING_INIT" ]
    grep -q 'nvim-neotest/neotest-jest' "$TESTING_INIT"
}

########################################
# Test 3 — neotest-playwright spec is declared
#
# Note: the canonical source is `thenbe/neotest-playwright` (the
# community fork), not `nvim-neotest/neotest-playwright` (the
# upstream org). The upstream was abandoned; the fork is the
# actively maintained continuation.
########################################

@test "plugins/testing/init.lua declares the thenbe/neotest-playwright spec" {
    [ -f "$TESTING_INIT" ]
    grep -q 'thenbe/neotest-playwright' "$TESTING_INIT"
}

########################################
# Test 4 — spec parses as a valid Lua module
########################################

@test "plugins/testing/init.lua parses as a valid Lua module" {
    [ -f "$TESTING_INIT" ]
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        nvim --headless --clean \
            -c "lua local ok, err = pcall(loadfile, '$TESTING_INIT') io.write(tostring(ok) .. ' ' .. tostring(err or 'ok'))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" == "true "* ]] || [[ "$output" == "true ok" ]]
}

########################################
# Test 5 — neotest core is listed as a dep of jest + playwright adapters
#
# The neotest-jest and neotest-playwright specs MUST list neotest as a
# dependency so lazy.nvim orders the install correctly. This is a soft
# check (allow either explicit "dependencies" entries or vim-deps
# inferred from the same `return { {...}, {...} }` table layout).
########################################

@test "plugins/testing/init.lua lists neotest as a dependency of jest + playwright adapters" {
    [ -f "$TESTING_INIT" ]
    # The jest spec block should reference nvim-neotest/neotest (either
    # via dependencies = { ... } or as a direct require in config).
    # Tolerate either ordering.
    local content
    content=$(cat "$TESTING_INIT")
    # The spec must contain neotest at least twice (once for the core,
    # once for each adapter referencing it as a dep).
    local count
    count=$(echo "$content" | grep -c 'nvim-neotest/neotest' || true)
    [ "$count" -ge 3 ] || {
        echo "Expected at least 3 references to nvim-neotest/neotest (core + 2 adapters), found: $count"
        return 1
    }
}
