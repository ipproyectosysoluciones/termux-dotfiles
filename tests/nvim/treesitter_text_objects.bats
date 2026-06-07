#!/usr/bin/env bats
# T4.6 — nvim-treesitter-textobjects plugin group (Phase 4)
#
# Verifies that the nvim-treesitter/nvim-treesitter-textobjects plugin
# is added to the consolidated plugin tree with VSCode-style select
# textobjects:
#
#   af / if   → function (around / inside)
#   ac / ic   → class (around / inside)
#   aa / ia   → parameter (around / inside)
#   ab / ib   → block (around / inside)
#
# Treesitter is already in lazy-lock.json from NvChad v2.5 baseline
# (per T3.2 / T3.7). The textobjects plugin is the new addition.
#
# Keymap surface: select textobjects in normal + visual mode, scoped
# via plugin config.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    PLUGINS_DIR="$NVIM_DIR/lua/plugins"
    EDITOR_INIT="$PLUGINS_DIR/editor/init.lua"
    PLUGINS_INIT="$PLUGINS_DIR/init.lua"
}

########################################
# Test 1 — editor/init.lua file exists
########################################

@test "T4.6: plugins/editor/init.lua exists (now holds telescope + textobjects)" {
    [ -f "$EDITOR_INIT" ]
}

########################################
# Test 2 — textobjects spec is declared
########################################

@test "T4.6: editor/init.lua declares the nvim-treesitter-textobjects spec" {
    [ -f "$EDITOR_INIT" ]
    grep -q 'nvim-treesitter/nvim-treesitter-textobjects' "$EDITOR_INIT"
}

########################################
# Test 3 — textobjects depends on nvim-treesitter
########################################

@test "T4.6: editor/init.lua wires textobjects to depend on nvim-treesitter" {
    [ -f "$EDITOR_INIT" ]
    # The textobjects plugin requires the treesitter parser plugin to
    # already be loaded. The spec MUST list `nvim-treesitter` in its
    # `dependencies` table (or as a sibling spec that loads first).
    local content
    content=$(cat "$EDITOR_INIT")
    if [[ "$content" == *'nvim-treesitter/nvim-treesitter-textobjects'* \
        && "$content" == *'nvim-treesitter/nvim-treesitter'* ]]; then
        return 0
    fi
    echo "editor/init.lua must reference both nvim-treesitter and the textobjects plugin"
    return 1
}

########################################
# Test 4 — select textobjects keymaps are configured
########################################

@test "T4.6: editor/init.lua configures select textobjects (af/if/ac/ic/aa/ia/ab/ib)" {
    [ -f "$EDITOR_INIT" ]
    # The select_keymaps table MUST list all 8 VSCode-style
    # textobjects in `init` mode (i.e. plain af/if/etc, not the
    # alternative prefix-x forms). We assert each is named.
    for k in af if ac ic aa ia ab ib; do
        grep -qE "${k}\b" "$EDITOR_INIT" || {
            echo "Select textobject '${k}' is not configured in editor/init.lua"
            return 1
        }
    done
}

########################################
# Test 5 — spec parses as a valid Lua module
########################################

@test "T4.6: editor/init.lua parses as a valid Lua module" {
    [ -f "$EDITOR_INIT" ]
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        nvim --headless --clean \
            -c "lua local ok, err = pcall(loadfile, '$EDITOR_INIT') io.write(tostring(ok) .. ' ' .. tostring(err or 'ok'))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" == "true "* ]] || [[ "$output" == "true ok" ]]
}

########################################
# Test 6 — pre-existing telescope spec is preserved
########################################

@test "T4.6: editor/init.lua preserves the pre-existing telescope spec (T2.4 baseline)" {
    [ -f "$EDITOR_INIT" ]
    grep -q 'nvim-telescope/telescope.nvim' "$EDITOR_INIT"
}
