#!/usr/bin/env bats

# T4.4 — Which-key desc coverage audit
# Every `<leader>*` keymap in mappings.lua MUST have a `desc` field in its opts table.

PROJECT_ROOT="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth"
MAPPINGS_FILE="$PROJECT_ROOT/nvim/lua/mappings.lua"

@test "all <leader> keymap calls have a desc field" {
  [ -f "$MAPPINGS_FILE" ]

  # Parse all map() calls with <leader> and verify each has desc.
  # Uses perl (slurp mode) to handle multi-line map blocks.
  local errors
  errors=$(perl -0777 -ne '
    my $content = $_;
    my @failures;
    while ($content =~ /map\s*\((?:[^)]*?)<leader>(?:[^)]*?)\{([[:print:]]*?)\}/gx) {
      my $opts = $1 // "";
      unless ($opts =~ /desc\s*=/x) {
        my $match = $&;
        $match =~ /<leader>([^"]*)"/;
        my $key = "<leader>" . ($1 // "?");
        push @failures, $key;
      }
    }
    if (@failures) {
      print "MISSING desc: " . join(", ", @failures) . "\n";
      exit 1;
    }
    exit 0;
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