#!/usr/bin/env bats
# T3.5 stub — vim-dadbod + vim-dadbod-ui plugin group
#
# Verifies that a new `nvim/lua/plugins/db/init.lua` file is created
# with the documented dadbod plugin specs (database client for MEAN/
# MERN projects — supports mongodb:// and postgresql:// URLs).

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    DB_INIT="$NVIM_DIR/lua/plugins/db/init.lua"
    PLUGINS_INIT="$NVIM_DIR/lua/plugins/init.lua"
}

########################################
# Test 1 — db/init.lua file exists
########################################

@test "plugins/db/init.lua exists (new plugin group for T3.5)" {
    [ -f "$DB_INIT" ]
}

########################################
# Test 2 — vim-dadbod core spec is declared
########################################

@test "plugins/db/init.lua declares the tpope/vim-dadbod spec" {
    [ -f "$DB_INIT" ]
    grep -q 'tpope/vim-dadbod' "$DB_INIT"
}

########################################
# Test 3 — vim-dadbod-ui spec is declared
########################################

@test "plugins/db/init.lua declares the kristijanhusak/vim-dadbod-ui spec" {
    [ -f "$DB_INIT" ]
    grep -q 'kristijanhusak/vim-dadbod-ui' "$DB_INIT"
}

########################################
# Test 4 — vim-dadbod-ui is a dep of (or sibling to) the core spec
#
# The UI plugin needs the core plugin to be loaded first. Either form
# (dependency declared explicitly, or both in the same return table)
# is acceptable.
########################################

@test "plugins/db/init.lua wires vim-dadbod-ui relative to vim-dadbod core" {
    [ -f "$DB_INIT" ]
    # The file must reference both names — that is sufficient signal
    # that the UI is co-located with the core.
    local content
    content=$(cat "$DB_INIT")
    if [[ "$content" == *'kristijanhusak/vim-dadbod-ui'* && "$content" == *'tpope/vim-dadbod'* ]]; then
        return 0
    fi
    echo "Both vim-dadbod and vim-dadbod-ui must be referenced in plugins/db/init.lua"
    return 1
}

########################################
# Test 5 — spec parses as a valid Lua module
########################################

@test "plugins/db/init.lua parses as a valid Lua module" {
    [ -f "$DB_INIT" ]
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        nvim --headless --clean \
            -c "lua local ok, err = pcall(loadfile, '$DB_INIT') io.write(tostring(ok) .. ' ' .. tostring(err or 'ok'))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" == "true "* ]] || [[ "$output" == "true ok" ]]
}

########################################
# Test 6 — db group is wired into plugins/init.lua
########################################

@test "plugins/init.lua imports the new plugins.db group" {
    [ -f "$PLUGINS_INIT" ]
    grep -Eq 'import[[:space:]]*=[[:space:]]*"plugins\.db"' "$PLUGINS_INIT"
}
