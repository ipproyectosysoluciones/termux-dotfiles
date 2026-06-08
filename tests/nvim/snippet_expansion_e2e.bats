#!/usr/bin/env bats
# T6.5 — E2E snippet expansion test (Phase 6)
#
# Verifies that luasnip loads correctly and snippet packs are available.
# Tests:
#   1. luasnip module loads
#   2. snippets directory exists with package.json
#   3. snippet packs for react, angular, express, mongoose are present
#   4. luasnip.loaders.from_vscode is called in snippets/init.lua

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    SNIPPETS_DIR="$PROJECT_ROOT/nvim/snippets"
    SNIPPETS_INIT="$PROJECT_ROOT/nvim/lua/plugins/snippets/init.lua"
}

########################################
# Test 1 — luasnip module loads
########################################
@test "luasnip module loads in headless nvim" {
    run nvim --headless \
        -c "lua package.path = '$PROJECT_ROOT/nvim/lua/?.lua;$PROJECT_ROOT/nvim/lua/?/init.lua;' .. package.path" \
        -c "lua require('luasnip')" \
        -c "q!" 2>&1
    [ "$status" -eq 0 ]
}

########################################
# Test 2 — snippets directory exists
########################################
@test "snippets directory exists" {
    [ -d "$SNIPPETS_DIR" ]
}

########################################
# Test 3 — package.json exists in snippets/
########################################
@test "snippets/package.json exists" {
    [ -f "$SNIPPETS_DIR/package.json" ]
}

@test "snippets/package.json is valid JSON" {
    run python3 -c "import json; json.load(open('$SNIPPETS_DIR/package.json'))"
    [ "$status" -eq 0 ]
}

########################################
# Test 4 — stack snippet packs are present
########################################
@test "react snippet pack is present" {
    [ -d "$SNIPPETS_DIR/react" ]
    run ls "$SNIPPETS_DIR/react/"*.json 2>/dev/null
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 1 ]
}

@test "angular snippet pack is present" {
    [ -d "$SNIPPETS_DIR/angular" ]
    run ls "$SNIPPETS_DIR/angular/"*.json 2>/dev/null
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 1 ]
}

@test "express snippet pack is present" {
    [ -d "$SNIPPETS_DIR/express" ]
    run ls "$SNIPPETS_DIR/express/"*.json 2>/dev/null
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 1 ]
}

@test "mongoose snippet pack is present" {
    [ -d "$SNIPPETS_DIR/mongoose" ]
    run ls "$SNIPPETS_DIR/mongoose/"*.json 2>/dev/null
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 1 ]
}

########################################
# Test 5 — snippets/init.lua uses from_vscode loader
########################################
@test "snippets/init.lua uses luasnip.loaders.from_vscode" {
    [ -f "$SNIPPETS_INIT" ]
    run grep -E "from_vscode" "$SNIPPETS_INIT"
    [ "$status" -eq 0 ]
}

########################################
# Test 6 — snippets/init.lua loads from snippets/ path
########################################
@test "snippets/init.lua loads from the snippets/ directory" {
    run grep -E "snippets" "$SNIPPETS_INIT"
    [ "$status" -eq 0 ]
}

########################################
# Test 7 — react snippet has rfc trigger
########################################
@test "react snippet has rfc trigger (React Functional Component)" {
    run python3 -c "
import json, os
react_dir = '$SNIPPETS_DIR/react'
files = [f for f in os.listdir(react_dir) if f.endswith('.json')]
for f in files:
    with open(os.path.join(react_dir, f)) as fp:
        data = json.load(fp)
        for body in data.values():
            if isinstance(body, dict) and 'prefix' in body:
                prefixes = body['prefix'] if isinstance(body['prefix'], list) else [body['prefix']]
                if 'rfc' in prefixes:
                    print('found')
                    exit(0)
print('not found')
exit(1)
"
    [ "$status" -eq 0 ]
    [ "$output" = "found" ]
}

########################################
# Test 8 — angular snippet has asc/asvc trigger
########################################
@test "angular snippet has asc or asvc trigger (@Component/@Injectable)" {
    run python3 -c "
import json, os
angular_dir = '$SNIPPETS_DIR/angular'
files = [f for f in os.listdir(angular_dir) if f.endswith('.json')]
for f in files:
    with open(os.path.join(angular_dir, f)) as fp:
        data = json.load(fp)
        for body in data.values():
            if isinstance(body, dict) and 'prefix' in body:
                prefixes = body['prefix'] if isinstance(body['prefix'], list) else [body['prefix']]
                if 'asc' in prefixes or 'asvc' in prefixes:
                    print('found')
                    exit(0)
print('not found')
exit(1)
"
    [ "$status" -eq 0 ]
    [ "$output" = "found" ]
}

########################################
# Test 9 — express snippet has ert/emw trigger
########################################
@test "express snippet has ert or emw trigger (Router/Request)" {
    run python3 -c "
import json, os
express_dir = '$SNIPPETS_DIR/express'
files = [f for f in os.listdir(express_dir) if f.endswith('.json')]
for f in files:
    with open(os.path.join(express_dir, f)) as fp:
        data = json.load(fp)
        for body in data.values():
            if isinstance(body, dict) and 'prefix' in body:
                prefixes = body['prefix'] if isinstance(body['prefix'], list) else [body['prefix']]
                if 'ert' in prefixes or 'emw' in prefixes:
                    print('found')
                    exit(0)
print('not found')
exit(1)
"
    [ "$status" -eq 0 ]
    [ "$output" = "found" ]
}

########################################
# Test 10 — mongoose snippet has ms/msd trigger
########################################
@test "mongoose snippet has ms or msd trigger (Schema/model)" {
    run python3 -c "
import json, os
mongoose_dir = '$SNIPPETS_DIR/mongoose'
files = [f for f in os.listdir(mongoose_dir) if f.endswith('.json')]
for f in files:
    with open(os.path.join(mongoose_dir, f)) as fp:
        data = json.load(fp)
        for body in data.values():
            if isinstance(body, dict) and 'prefix' in body:
                prefixes = body['prefix'] if isinstance(body['prefix'], list) else [body['prefix']]
                if 'ms' in prefixes or 'msd' in prefixes:
                    print('found')
                    exit(0)
print('not found')
exit(1)
"
    [ "$status" -eq 0 ]
    [ "$output" = "found" ]
}