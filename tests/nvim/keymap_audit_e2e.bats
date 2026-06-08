#!/usr/bin/env bats
# T6.3 — E2E keymap audit (Phase 6)
#
# Verifies that all documented keymaps are registered in nvim/lua/mappings.lua.
# Parses the Lua file directly to extract keymap declarations and validates
# the key groups are present.
#
# Keymap groups being verified:
#   AI in-editor (CodeCompanion): <leader>aa, ai, at, am, as
#   AI CLI splits (tmux): <leader>ag, ac, ao, gm, gg
#   Git (gitsigns): <leader>gb, gp, gd
#   GitHub (octo): <leader>op, oi, or
#   File tree: <leader>e
#   Diagnostics: <leader>de
#   Terminal: <leader>tt
#   DB: <leader>db

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    MAPPINGS="$PROJECT_ROOT/nvim/lua/mappings.lua"
}

########################################
# Test 1 — mappings.lua exists
########################################
@test "mappings.lua exists" {
    [ -f "$MAPPINGS" ]
}

########################################
# Test 2 — AI in-editor keymaps (CodeCompanion)
########################################
@test "CodeCompanion keymaps are registered (aa, ai, at, am, as)" {
    run grep -E "leader.*aa|leader.*ai|leader.*at|leader.*am|leader.*as" "$MAPPINGS"
    [ "$status" -eq 0 ]
    # Should find at least 5 lines for the 5 CodeCompanion keymaps
    [ $(echo "$output" | wc -l) -ge 5 ]
}

########################################
# Test 3 — AI CLI split keymaps
########################################
@test "AI CLI split keymaps are registered (ag, ac, ao, gm, gg)" {
    run grep -E "leader.*ag|leader.*ac|leader.*ao|leader.*gm|leader.*gg" "$MAPPINGS"
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 5 ]
}

########################################
# Test 4 — Git (gitsigns) keymaps
########################################
@test "gitsigns keymaps are registered (gb, gp, gd)" {
    # gitsigns keymaps are defined in plugins/git/init.lua, not mappings.lua
    local GIT_INIT="$PROJECT_ROOT/nvim/lua/plugins/git/init.lua"
    run grep -E "leader.*gb|leader.*gp|leader.*gd" "$GIT_INIT"
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 3 ]
}

########################################
# Test 5 — GitHub (octo) keymaps
########################################
@test "octo keymaps are registered (op, oi, or)" {
    run grep -E "leader.*op|leader.*oi|leader.*or" "$MAPPINGS"
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 3 ]
}

########################################
# Test 6 — NvimTree toggle
########################################
@test "NvimTree toggle keymap is registered (<leader>e)" {
    run grep -E 'leader.*e.*NvimTreeToggle' "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 7 — Diagnostic float
########################################
@test "diagnostic float keymap is registered (<leader>de)" {
    run grep -E 'leader.*de.*open_float' "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 8 — Terminal toggle
########################################
@test "terminal toggle keymap is registered (<leader>tt)" {
    run grep -E 'leader.*tt.*ToggleTerm' "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 9 — DB toggle
########################################
@test "database toggle keymap is registered (<leader>db)" {
    run grep -E 'leader.*db.*DBUIToggle' "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 10 — Treesitter textobject keymaps (af, if, ac, ic, aa, ia, ab, ib)
########################################
@test "treesitter textobject keymaps are registered (af, if, ac, ic, aa, ia, ab, ib)" {
    # These are configured in plugins/editor/init.lua, not in mappings.lua
    local EDITOR_INIT="$PROJECT_ROOT/nvim/lua/plugins/editor/init.lua"
    run grep -E '"af"|"if"|"ac"|"ic"|"aa"|"ia"|"ab"|"ib"' "$EDITOR_INIT"
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 8 ]
}

########################################
# Test 11 — Telescope keymaps (ff, fg, fb, fh)
########################################
@test "Telescope keymaps are registered (ff, fg, fb, fh)" {
    run grep -E "leader.*ff.*find_files|leader.*fg.*live_grep|leader.*fb.*buffers|leader.*fh.*help_tags" "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 12 — Format keymaps (fm, fs, fq)
########################################
@test "format keymaps are registered (fm, fs, fq)" {
    run grep -E "leader.*fm.*conform|leader.*fs.*shfmt|leader.*fq.*psqlformat" "$MAPPINGS"
    [ "$status" -eq 0 ]
}

########################################
# Test 13 — Which-key group labels registered
########################################
@test "which-key timeoutlen is set in ui/init.lua" {
    local UI_INIT="$PROJECT_ROOT/nvim/lua/plugins/ui/init.lua"
    run grep -E "timeoutlen.*500" "$UI_INIT"
    [ "$status" -eq 0 ]
}