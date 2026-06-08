#!/usr/bin/env bats

# T4.4 — Which-key desc coverage audit
# Every `<leader>*` keymap in mappings.lua MUST have a `desc` field in its opts table.

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
MAPPINGS_FILE="$PROJECT_ROOT/nvim/lua/mappings.lua"

@test "all <leader> keymap calls have a desc field" {
  [ -f "$MAPPINGS_FILE" ]

  # For each <leader> key, verify there's a desc in the same OR the next 2 lines.
  local line_num=0
  local errors=""
  
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    if echo "$line" | grep -q 'map\s*\(\s*"n"\s*,\s*"<leader>'; then
      local block="$line"
      for i in 1 2; do
        if IFS= read -r next; then
          line_num=$((line_num + 1))
          block="$block"$'\n'"$next"
        fi
      done
      if ! echo "$block" | grep -q 'desc\s*='; then
        local key=$(echo "$line" | grep -o '<leader>[^"]*' | head -1)
        errors="$errors"$'\n'"MISSING desc: $key at line $((line_num - 1))"
      fi
    fi
  done < "$MAPPINGS_FILE"
  
  [ -z "$errors" ] || {
    echo "$errors" >&2
    return 1
  }
}

@test "AI prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>a' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}

@test "file prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>f' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}

@test "terminal prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>t' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}

@test "git prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>g' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}

@test "diagnostic prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>d' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}

@test "split/window prefix group has desc fields" {
  grep -E 'map\s*\(\s*"n"\s*,\s*"<leader>s' "$MAPPINGS_FILE" | grep -q 'desc\s*='
}
