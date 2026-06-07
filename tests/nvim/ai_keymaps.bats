#!/usr/bin/env bats
# T2.3 / T2.4 / T2.5 / T6.3 stub — AI keymap coverage
#
# Verifies that `nvim/lua/mappings.lua` declares the documented AI
# keymap surface for Phase 2:
#
#   In-editor CodeCompanion (T2.3):
#     <leader>aa  normal + visual → CodeCompanionChat
#     <leader>ai  normal + visual → CodeCompanion (inline)
#     <leader>at  normal         → CodeCompanionChat -t (toggle)
#     <leader>am  normal         → CodeCompanionActions
#     <leader>as  normal         → CodeCompanionChat -s (switch)
#
#   Terminal-spawn CLI splits (T2.4):
#     <leader>ag  normal         → ai_split("gemini",   scripts/.../gemini.sh)
#     <leader>ac  normal         → ai_split("claude",   scripts/.../claude.sh)
#     <leader>ao  normal         → ai_split("opencode", scripts/.../opencode.sh)
#     <leader>gm  normal         → ai_split("mistral",  scripts/.../mistral.sh)
#     # Note: <leader>am is CodeCompanion's actions; mistral moved to <leader>gm
#     # to resolve the Phase 1 collision.
#
#   Gentle CLI parity (T2.5):
#     <leader>gg  normal         → ai_split("gentle",   scripts/.../gentle.sh)
#
# Every binding MUST carry a non-empty `desc` field (which-key
# convention per T4.4). The mappings file MUST load headlessly with
# no E5108/E5113 (Lua errors).

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    MAPPINGS_FILE="$NVIM_DIR/lua/mappings.lua"
    PROVIDERS_DIR="$PROJECT_ROOT/scripts/ai/providers"
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
# Test 1 — <leader>aa (n)
########################################

@test "<leader>aa in normal mode is registered" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "aa"
}

########################################
# Test 2 — <leader>ai (n)
########################################

@test "<leader>ai in normal mode is registered" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "ai"
}

########################################
# Test 3 — <leader>at, <leader>am, <leader>as registered
########################################

@test "<leader>at, <leader>am, <leader>as are all registered in normal mode" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    for k in at am as; do
        assert_binding_registered "n" "$k"
    done
}

########################################
# Test 4 — visual-mode <leader>aa + <leader>ai registered
########################################

@test "<leader>aa and <leader>ai in visual mode are registered" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "v" "aa"
    assert_binding_registered "v" "ai"
}

########################################
# Test 5 — 4 tmux-split AI keymaps registered
########################################

@test "terminal-split AI keymaps <leader>ag/ac/ao/gm are registered" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    for k in ag ac ao gm; do
        assert_binding_registered "n" "$k"
    done
}

########################################
# Test 6 — gentle parity <leader>gg
########################################

@test "gentle CLI parity keymap <leader>gg is registered" {
    run extract_keymap_bindings
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ LOAD_ERROR ]] || { echo "$output"; return 1; }
    assert_binding_registered "n" "gg"
}

########################################
# Test 7 — every AI keymap has a non-empty desc field
########################################

@test "every AI keymap has a non-empty desc field (which-key requirement)" {
    [ -f "$MAPPINGS_FILE" ]
    # Find all AI keymap lines (a* and g* in <leader>) and check that
    # each contains a desc= field.
    local offenders
    offenders=$(grep -nE 'map\("(n|v)"?, *"(<leader>| )(a[a-z]|g[a-z])",' "$MAPPINGS_FILE" \
        | grep -v 'desc\s*=' || true)
    if [[ -n "$offenders" ]]; then
        echo "AI keymap(s) missing desc field:"
        echo "$offenders"
        return 1
    fi
}

########################################
# Test 8 — keymap file references every required provider script path
########################################

@test "mappings.lua references the 4 provider scripts + gentle" {
    [ -f "$MAPPINGS_FILE" ]
    for p in gemini.sh claude.sh opencode.sh mistral.sh gentle.sh; do
        [ -f "$PROVIDERS_DIR/$p" ] || { echo "Missing provider script: $p"; return 1; }
        grep -q "$p" "$MAPPINGS_FILE" || {
            echo "mappings.lua does not reference provider script: $p"
            return 1
        }
    done
}

########################################
# Test 9 — <leader>am is CodeCompanion, NOT mistral
########################################

@test "<leader>am is CodeCompanion actions, NOT mistral split (collision resolved)" {
    [ -f "$MAPPINGS_FILE" ]
    local am_line
    am_line=$(grep -nE 'map\("n", *"<leader>am"|map\("n", *" am"' "$MAPPINGS_FILE" || true)
    if [[ -z "$am_line" ]]; then
        echo "<leader>am is not registered at all"
        return 1
    fi
    if echo "$am_line" | grep -q 'mistral'; then
        echo "<leader>am collides with mistral split — should be CodeCompanion actions"
        return 1
    fi
}

########################################
# Test 10 — headless nvim loads mappings.lua with no Lua errors
########################################

@test "mappings.lua loads headlessly with no Lua errors and no E492" {
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
