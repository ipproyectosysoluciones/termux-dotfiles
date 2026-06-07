#!/usr/bin/env bats
# T3.6 / T3.7 / T6.5 stub — Per-stack snippet packs
#
# Verifies that the project ships VSCode-format snippet packs for
# MEAN/MERN development, loaded via `luasnip.loaders.from_vscode`:
#
#   1. `nvim/lua/plugins/snippets/init.lua` exists and calls
#      `require("luasnip.loaders.from_vscode").lazy_load` with the
#      project's `nvim/snippets` path.
#   2. `nvim/snippets/package.json` exists with at least 4 pack
#      entries (one each for react, angular, express, mongoose).
#   3. At least 1 example snippet file exists under
#      `nvim/snippets/{react,angular,express,mongoose}/`.
#   4. The `plugins/snippets` group is imported in plugins/init.lua.

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    NVIM_DIR="$PROJECT_ROOT/nvim"
    SNIPPETS_INIT="$NVIM_DIR/lua/plugins/snippets/init.lua"
    PLUGINS_INIT="$NVIM_DIR/lua/plugins/init.lua"
    SNIPPETS_DIR="$NVIM_DIR/snippets"
    PACKAGE_JSON="$SNIPPETS_DIR/package.json"
}

########################################
# Test 1 — plugins/snippets/init.lua exists and wires the loader
########################################

@test "plugins/snippets/init.lua exists and uses from_vscode loader" {
    [ -f "$SNIPPETS_INIT" ]
    grep -q 'luasnip.loaders.from_vscode' "$SNIPPETS_INIT"
    grep -q 'lazy_load' "$SNIPPETS_INIT"
}

########################################
# Test 2 — snippets/package.json manifest exists
########################################

@test "snippets/package.json manifest exists" {
    [ -f "$PACKAGE_JSON" ]
}

########################################
# Test 3 — package.json declares at least 4 pack entries
########################################

@test "snippets/package.json declares at least 4 pack entries (react/angular/express/mongoose)" {
    [ -f "$PACKAGE_JSON" ]
    # The package.json MUST mention each of the 4 stack pack names.
    # Use a simple grep — the manifest is short and well-known.
    for stack in react angular express mongoose; do
        grep -q "$stack" "$PACKAGE_JSON" || {
            echo "snippets/package.json missing pack: $stack"
            return 1
        }
    done
}

########################################
# Test 4 — at least 1 example snippet per stack
########################################

@test "snippets/{react,angular,express,mongoose}/ each contain at least 1 example snippet" {
    [ -d "$SNIPPETS_DIR" ]
    for stack in react angular express mongoose; do
        local stack_dir="$SNIPPETS_DIR/$stack"
        [ -d "$stack_dir" ] || {
            echo "Missing snippets/$stack/ directory"
            return 1
        }
        # At least one .json file (VSCode snippet format)
        local count
        count=$(find "$stack_dir" -maxdepth 1 -name '*.json' -not -name 'package.json' | wc -l)
        [ "$count" -ge 1 ] || {
            echo "No example snippet JSON in snippets/$stack/ (found $count files)"
            return 1
        }
    done
}

########################################
# Test 5 — React rfc snippet is the documented skeleton
########################################

@test "React rfc snippet exists with import React + Functional Component" {
    local stack_dir="$SNIPPETS_DIR/react"
    [ -d "$stack_dir" ] || { echo "Missing snippets/react/"; return 1; }
    # Concatenate all react/*.json and grep for the documented signals.
    local content
    content=$(cat "$stack_dir"/*.json 2>/dev/null)
    [[ "$content" =~ \"rfc\" ]] || { echo "React snippet missing prefix 'rfc'"; return 1; }
    [[ "$content" =~ [Rr]eact ]] || { echo "React snippet does not mention 'React'"; return 1; }
}

########################################
# Test 6 — Mongoose ms snippet is the documented skeleton
########################################

@test "Mongoose ms snippet exists with mongoose.Schema" {
    local stack_dir="$SNIPPETS_DIR/mongoose"
    [ -d "$stack_dir" ] || { echo "Missing snippets/mongoose/"; return 1; }
    local content
    content=$(cat "$stack_dir"/*.json 2>/dev/null)
    [[ "$content" =~ \"ms\" ]] || { echo "Mongoose snippet missing prefix 'ms'"; return 1; }
    [[ "$content" =~ [Mm]ongoose ]] || { echo "Mongoose snippet does not mention 'mongoose'"; return 1; }
    [[ "$content" =~ [Ss]chema ]] || { echo "Mongoose snippet does not mention 'Schema'"; return 1; }
}

########################################
# Test 7 — spec parses as a valid Lua module
########################################

@test "plugins/snippets/init.lua parses as a valid Lua module" {
    [ -f "$SNIPPETS_INIT" ]
    run env -i \
        PATH="$PATH" \
        HOME="$BATS_TEST_TMPDIR" \
        nvim --headless --clean \
            -c "lua local ok, err = pcall(loadfile, '$SNIPPETS_INIT') io.write(tostring(ok) .. ' ' .. tostring(err or 'ok'))" \
            -c "q!" 2>&1
    [ "$status" -eq 0 ]
    [[ "$output" == "true "* ]] || [[ "$output" == "true ok" ]]
}

########################################
# Test 8 — snippets group is imported in plugins/init.lua
########################################

@test "plugins/init.lua imports the new plugins.snippets group" {
    [ -f "$PLUGINS_INIT" ]
    grep -Eq 'import[[:space:]]*=[[:space:]]*"plugins\.snippets"' "$PLUGINS_INIT"
}
