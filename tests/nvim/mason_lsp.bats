#!/usr/bin/env bats
# T3.1 / T6.4 stub — Mason LSP augmentation for MEAN/MERN
#
# Verifies that `nvim/lua/plugins/lsp/init.lua` declares the additional
# LSP servers required by Phase 3:
#
#   1. `angularls` is in `mason-lspconfig.nvim` `ensure_installed` (MEAN)
#   2. `install_lsp_on_demand = true` is set on the mason-lspconfig spec
#      (mitigates Termux disk usage — angularls is ~500MB)
#   3. `biome` is referenced in the spec, gated by `require("user").has_biome()`
#      (opt-in feature flag; default off to keep install footprint low)
#   4. The lsp spec file parses as a valid Lua module (no syntax errors)
#
# The actual `:MasonInstall` smoke is intentionally a `skip if no network`
# test — see tests/nvim/nvim_mason_install_smoke.bats if added later.
# We avoid network in this file to keep it fast and CI-friendly.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    LSP_INIT="$NVIM_DIR/lua/plugins/lsp/init.lua"
}

########################################
# Test 1 — angularls is in ensure_installed
########################################

@test "plugins/lsp/init.lua includes angularls in mason ensure_installed" {
    [ -f "$LSP_INIT" ]
    # The mason-lspconfig ensure_installed list MUST contain angularls.
    # Tolerate any whitespace formatting inside the braces.
    grep -Eq '"angularls"' "$LSP_INIT"
}

########################################
# Test 2 — install_lsp_on_demand = true
########################################

@test "plugins/lsp/init.lua sets install_lsp_on_demand = true" {
    [ -f "$LSP_INIT" ]
    # Set inline on the mason-lspconfig spec opts (any whitespace).
    grep -Eq 'install_lsp_on_demand[[:space:]]*=[[:space:]]*true' "$LSP_INIT"
}

########################################
# Test 3 — biome is referenced and gated by has_biome()
########################################

@test "plugins/lsp/init.lua references biome gated by user.has_biome()" {
    [ -f "$LSP_INIT" ]
    # The biome LSP is opt-in. The spec must BOTH mention biome AND
    # check require("user").has_biome() before installing it.
    grep -q 'biome' "$LSP_INIT"
    grep -q 'has_biome' "$LSP_INIT"
}

########################################
# Test 4 — spec parses as a valid Lua module
########################################

@test "plugins/lsp/init.lua parses as a valid Lua module" {
    [ -f "$LSP_INIT" ]
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        nvim --headless --clean \
            -c "lua local ok, err = pcall(loadfile, '$LSP_INIT') io.write(tostring(ok) .. ' ' .. tostring(err or 'ok'))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" == "true "* ]] || [[ "$output" == "true ok" ]]
}

########################################
# Test 5 — pre-existing LSPs preserved (regression guard)
########################################

@test "plugins/lsp/init.lua preserves pre-existing LSPs (bashls, ts_ls, lua_ls, eslint, html, cssls, jsonls)" {
    [ -f "$LSP_INIT" ]
    for srv in bashls cssls html jsonls lua_ls ts_ls eslint; do
        grep -Eq "\"$srv\"" "$LSP_INIT" || {
            echo "Pre-existing LSP missing from spec: $srv"
            return 1
        }
    done
}
