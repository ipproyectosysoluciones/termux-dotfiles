#!/usr/bin/env bats

# T4.4 — Which-key desc coverage audit
# Every `<leader>*` keymap in mappings.lua MUST have a `desc` field in its opts table.

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
MAPPINGS_FILE="$PROJECT_ROOT/nvim/lua/mappings.lua"

@test "all <leader> keymap calls have a desc field" {
  [ -f "$MAPPINGS_FILE" ]

  # Find all map() calls with <leader> and check each has desc.
  # Uses awk to parse multi-line map blocks without perl.
  local errors
  errors=$(awk '
    /map\s*\(/ {
      block = $0
      in_block = 1
    }
    in_block {
      block = block $0
      open = (open ? open : 0) + gsub(/\{/, "{") - gsub(/\}/, "}")
      if (open == 0 && block ~ /map\s*\(/) {
        if (block ~ /<leader>/ && block !~ /desc\s*=/) {
          # Extract the leader key
          if (match(block, /<leader>([^"]*)"/, arr)) {
            failures = failures "MISSING desc: <leader>" arr[1] "\n"
          } else {
            failures = failures "MISSING desc: <leader>? (parse error)\n"
          }
        }
        block = ""
        in_block = 0
        open = 0
      }
    }
    END {
      if (failures) {
        printf "%s", failures
        exit 1
      }
      exit 0
    }
  ' "$MAPPINGS_FILE" 2>&1) || {
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
