#!/usr/bin/env bats
# T6.6 — E2E bilingual lint test (Phase 6)
#
# Verifies that all 6 new bilingual docs have the correct structure:
#   1. ## ES section marker
#   2. ## EN section marker
#   3. section divider (---)
#   No placeholder text (TODO, FIXME, etc.)

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    DOCS_DIR="$PROJECT_ROOT/docs"
}

########################################
# Test 1 — neovim.md has bilingual markers
########################################
@test "docs/neovim.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/neovim.md"
    [ "$status" -eq 0 ]
}

@test "docs/neovim.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/neovim.md"
    [ "$status" -eq 0 ]
}

@test "docs/neovim.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/neovim.md"
    [ "$status" -eq 0 ]
    [ $(echo "$output" | wc -l) -ge 1 ]
}

########################################
# Test 2 — keymaps.md has bilingual markers
########################################
@test "docs/keymaps.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/keymaps.md"
    [ "$status" -eq 0 ]
}

@test "docs/keymaps.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/keymaps.md"
    [ "$status" -eq 0 ]
}

@test "docs/keymaps.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/keymaps.md"
    [ "$status" -eq 0 ]
}

########################################
# Test 3 — plugins.md has bilingual markers
########################################
@test "docs/plugins.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/plugins.md"
    [ "$status" -eq 0 ]
}

@test "docs/plugins.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/plugins.md"
    [ "$status" -eq 0 ]
}

@test "docs/plugins.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/plugins.md"
    [ "$status" -eq 0 ]
}

########################################
# Test 4 — ai-setup.md has bilingual markers
########################################
@test "docs/ai-setup.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/ai-setup.md"
    [ "$status" -eq 0 ]
}

@test "docs/ai-setup.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/ai-setup.md"
    [ "$status" -eq 0 ]
}

@test "docs/ai-setup.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/ai-setup.md"
    [ "$status" -eq 0 ]
}

########################################
# Test 5 — troubleshooting.md has bilingual markers
########################################
@test "docs/troubleshooting.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/troubleshooting.md"
    [ "$status" -eq 0 ]
}

@test "docs/troubleshooting.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/troubleshooting.md"
    [ "$status" -eq 0 ]
}

@test "docs/troubleshooting.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/troubleshooting.md"
    [ "$status" -eq 0 ]
}

########################################
# Test 6 — i18n.md has bilingual markers
########################################
@test "docs/i18n.md has ## ES marker" {
    run grep -n "## ES" "$DOCS_DIR/i18n.md"
    [ "$status" -eq 0 ]
}

@test "docs/i18n.md has ## EN marker" {
    run grep -n "## EN" "$DOCS_DIR/i18n.md"
    [ "$status" -eq 0 ]
}

@test "docs/i18n.md has section divider" {
    run grep -n "^---$" "$DOCS_DIR/i18n.md"
    [ "$status" -eq 0 ]
}

########################################
# Test 7 — no placeholder text in new docs
########################################
@test "docs/neovim.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/neovim.md" || true
    # Status should be 1 (not found) or output should be empty
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        # Found something — fail
        echo "$output"
        return 1
    fi
    return 0
}

@test "docs/keymaps.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/keymaps.md" || true
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        echo "$output"
        return 1
    fi
    return 0
}

@test "docs/plugins.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/plugins.md" || true
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        echo "$output"
        return 1
    fi
    return 0
}

@test "docs/ai-setup.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/ai-setup.md" || true
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        echo "$output"
        return 1
    fi
    return 0
}

@test "docs/troubleshooting.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/troubleshooting.md" || true
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        echo "$output"
        return 1
    fi
    return 0
}

@test "docs/i18n.md has no TODO/FIXME placeholders" {
    run grep -E "TODO|FIXME|XXX" "$DOCS_DIR/i18n.md" || true
    if [ "$status" -eq 0 ] && [ -n "$output" ]; then
        echo "$output"
        return 1
    fi
    return 0
}

########################################
# Test 8 — all 6 docs have substantial content
########################################
@test "all 6 new docs have at least 50 lines" {
    for doc in neovim.md keymaps.md plugins.md ai-setup.md troubleshooting.md i18n.md; do
        lines=$(wc -l < "$DOCS_DIR/$doc")
        if [ "$lines" -lt 50 ]; then
            echo "$doc has only $lines lines (expected ≥50)"
            exit 1
        fi
    done
    echo "all docs have ≥50 lines"
}