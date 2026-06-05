#!/usr/bin/env bats

PROJECT_ROOT="/media/bladimir/Datos1/Datos/proyectos/work/Termux-AI-Astaroth"
SCRIPT_DIR="$PROJECT_ROOT/scripts"

@test "release.sh shows usage when no command provided" {
    run "$SCRIPT_DIR/release.sh"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Usage: $SCRIPT_DIR/release.sh changelog" ]
}

@test "release.sh shows help with changelog command" {
    run "$SCRIPT_DIR/release.sh"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Commands:" ]
    [ "${lines[2]}" = "  changelog   Generate changelog entry and create release tag" ]
}

@test "release.sh validates VERSION file exists" {
    local temp_dir="$BATS_TEST_TMPDIR/test_no_version"
    mkdir -p "$temp_dir"

    # Run from temp_dir without VERSION file
    run bash -c "cd '$temp_dir' && '$SCRIPT_DIR/release.sh' changelog 2>&1"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Error: VERSION file not found" ]
}

@test "release.sh validates CHANGELOG.md has [Unreleased] section" {
    local temp_dir="$BATS_TEST_TMPDIR/test_no_unreleased"
    mkdir -p "$temp_dir"

    # Create fake git directory and VERSION file
    mkdir -p "$temp_dir/.git"
    echo "1.0.0" > "$temp_dir/VERSION"
    echo "# Changelog" > "$temp_dir/CHANGELOG.md"
    echo "" >> "$temp_dir/CHANGELOG.md"
    echo "## 1.0.0 - 2025-01-01" >> "$temp_dir/CHANGELOG.md"

    # Initialize git repo
    cd "$temp_dir"
    git init -q 2>/dev/null || true

    run bash -c "cd '$temp_dir' && '$SCRIPT_DIR/release.sh' changelog 2>&1"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "Error: No [Unreleased] section found in CHANGELOG.md" ]]
}

@test "release.sh validates tag doesn't exist" {
    local temp_dir="$BATS_TEST_TMPDIR/test_tag_exists"
    mkdir -p "$temp_dir"

    # Create fake git directory with VERSION and CHANGELOG with [Unreleased]
    mkdir -p "$temp_dir/.git"
    echo "1.0.0" > "$temp_dir/VERSION"
    echo "# Changelog" > "$temp_dir/CHANGELOG.md"
    echo "" >> "$temp_dir/CHANGELOG.md"
    echo "## [Unreleased]" >> "$temp_dir/CHANGELOG.md"

    # Initialize git repo and create tag
    cd "$temp_dir"
    git init -q 2>/dev/null || true
    git config user.email "test@test.com" 2>/dev/null || true
    git config user.name "Test" 2>/dev/null || true
    git add . 2>/dev/null || true
    git commit -q -m "initial" 2>/dev/null || true
    git tag "v1.0.0" 2>/dev/null || true

    run bash -c "cd '$temp_dir' && '$SCRIPT_DIR/release.sh' changelog 2>&1"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "Error: Tag v1.0.0 already exists" ]]
}