#!/usr/bin/env bats
# T3.3 / T3.4 / T3.5 — Devtools keymap coverage (T6.3 stub, Phase 3 slice)
#
# Verifies that `nvim/lua/mappings.lua` declares the MEAN/MERN devtools
# keymap surface for Phase 3:
#
#   Integrated terminal (T3.3):
#     <leader>tt  normal         → :ToggleTerm (toggleterm.nvim)
#
#   File explorer (T3.4):
#     <leader>e   normal         → :NvimTreeToggle (collision resolved —
#                                   diagnostic float moved to <leader>de)
#     <leader>de  normal         → vim.diagnostic.open_float (was <leader>e)
#
#   Database client (T3.5):
#     <leader>db  normal         → :DBUIToggle (vim-dadbod-ui)
#
# Every binding MUST carry a non-empty `desc` field (T4.4 which-key
# convention). Reuses the same keymap-binding extractor pattern as
# tests/nvim/ai_keymaps.bats.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    MAPPINGS_FILE="$NVIM_DIR/lua/mappings.lua"
}

########################################
# Helper: extract every map(...) call from mappings.lua
#
# Hooks vim.keymap.set before requiring the mappings module, then
# prints each registered (mode, lhs) on its own tab-separated line.
########################################

extract_keymap_bindings() {
    nvim --headless --clean \
        -c "lua package.path = '$NVIM_DIR/lua/?.lua;$NVIM_DIR/lua/?/init.lua;' .. package.path" \
        -c "lua package.preload['nvchad.mappings'] = function() return {} end" \
        -c "lua
            local out = {}
            local original = vim.keymap.set
            vim.keymap.set = function(mode, lhs, rhs, opts)
                if type(mode) == 'string' and type(lhs) == 'string' then
                    table.insert(out, mode .. '\t' .. lhs)
                end
                return original(mode, lhs, rhs, opts)
            end
            local ok, err = pcall(require, 'mappings')
            if not ok then io.write('LOAD_ERROR\t' .. tostring(err)) io.flush() return end
            for _, line in ipairs(out) do io.write(line .. '\n') end" \
        -c "q!" 2>&1
}

########################################
# Helper: assert a (mode, lhs) binding is registered
#
# grep -E does NOT interpret \t as a tab, so we embed a literal tab
# via $(printf '\t'). We accept <leader>lhs (headless default), <Space>lhs
# (when leader is set to space at runtime), and a literal-space lhs.
########################################

assert_binding_registered() {
    local mode="$1"
    local lhs="$2"
    local tab
    tab="$(printf '\t')"
    if ! echo "$output" | grep -qE "^${mode}${tab}(<leader>|<Space>| )${lhs}\$"; then
        echo "Missing keymap: ${mode} <leader>${lhs}"
        echo "--- bindings dump ---"
        echo "$output" | head -50
        return 1
    fi
}

########################################
# T3.3 — toggleterm <leader>tt
########################################

@test "<leader>tt (toggleterm) is registered in normal mode" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "tt"
}

########################################
# T3.4 — nvim-tree <leader>e (collision resolved)
########################################

@test "<leader>e (nvim-tree) is registered in normal mode" {
    [ -f "$MAPPINGS_FILE" ]
    # T3.4: <leader>e moves from diagnostic-float to NvimTreeToggle.
    # The binding MAY already exist (it did, mapped to diagnostic.open_float),
    # so we must check the RHS is the NvimTree command — not just presence.
    local e_line
    e_line=$(grep -nE 'map\("n", *"(<leader>| )e"' "$MAPPINGS_FILE" || true)
    if [[ -z "$e_line" ]]; then
        echo "<leader>e is not registered at all"
        return 1
    fi
    if ! echo "$e_line" | grep -qE 'NvimTree|Toggle'; then
        echo "<leader>e is bound, but not to nvim-tree (collision unresolved):"
        echo "$e_line"
        return 1
    fi
}

########################################
# T3.4 — diagnostic float moved to <leader>de
########################################

@test "<leader>de (diagnostic float) is registered in normal mode" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "de"
}

########################################
# T3.5 — vim-dadbod <leader>db
########################################

@test "<leader>db (vim-dadbod UI) is registered in normal mode" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "db"
}

########################################
# T3.3 / T3.4 / T3.5 — every devtools keymap has a non-empty desc field
########################################

@test "every devtools keymap (tt, e, de, db) has a non-empty desc field" {
    [ -f "$MAPPINGS_FILE" ]
    # Sanity: each of the 4 devtools keymap lines MUST exist in mappings.lua.
    # If any is missing the test fails with a clear message.
    for k in tt e de db; do
        if ! grep -qE "map\(\"n\"?, *\"<leader>${k}\"" "$MAPPINGS_FILE"; then
            echo "Devtools keymap <leader>${k} is not declared in mappings.lua"
            return 1
        fi
    done
    # Then check each declared keymap line carries a desc= field.
    local offenders
    offenders=$(grep -nE 'map\("n"?, *"<leader>(tt|e|de|db)"' "$MAPPINGS_FILE" \
        | grep -v 'desc[[:space:]]*=' || true)
    if [[ -n "$offenders" ]]; then
        echo "Devtools keymap(s) missing desc field:"
        echo "$offenders"
        return 1
    fi
}

########################################
# T3.3 / T3.4 / T3.5 — mappings.lua loads headlessly with no Lua errors
########################################

@test "mappings.lua loads headlessly with no Lua errors after Phase 3 additions" {
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/.config" \
        XDG_DATA_HOME="$BATS_TEST_TMPDIR/.local/share" \
        XDG_STATE_HOME="$BATS_TEST_TMPDIR/.local/state" \
        XDG_CACHE_HOME="$BATS_TEST_TMPDIR/.cache" \
        timeout 60 nvim --headless \
            --cmd "set rtp+=$NVIM_DIR" \
            --cmd "set nomore" \
            --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
            -c "lua require('mappings')" \
            -c "messages" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ E5108 ]]
    [[ ! "$output" =~ E5113 ]]
    [[ ! "$output" =~ LOAD_ERROR ]]
}
