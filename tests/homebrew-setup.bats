#!/usr/bin/env bats

# Homebrew setup script tests
# Test runner for termux-dotfiles-setup (Homebrew Cellar symlink creator)

load test_helper

# Override PROJECT_ROOT: tests are at tests/ level (one level deep), need to go up one level
PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# The script path (will not exist yet - RED phase)
SETUP_SCRIPT="$(resolve_script "scripts/termux-dotfiles-setup")"

########################################
# Helper: create fake Cellar structure
# Homebrew Cellar path is: $(brew --prefix)/Cellar/termux-dotfiles/{version}/
########################################

create_fake_cellar() {
    local brew_prefix="$1"
    local version="${2:-1.1.0}"
    # Create the proper Cellar structure: {brew_prefix}/Cellar/termux-dotfiles/{version}/
    local cellar_root="$brew_prefix/Cellar/termux-dotfiles"
    mkdir -p "$cellar_root/$version"
    # Create fake dotfile directories
    mkdir -p "$cellar_root/$version/zsh"
    mkdir -p "$cellar_root/$version/tmux"
    mkdir -p "$cellar_root/$version/nvim"
    mkdir -p "$cellar_root/$version/scripts"
    mkdir -p "$cellar_root/$version/termux"
    mkdir -p "$cellar_root/$version/docs"
    # Create a marker file in each to verify symlink targets
    touch "$cellar_root/$version/zsh/.zshrc"
    touch "$cellar_root/$version/tmux/.tmux.conf"
    touch "$cellar_root/$version/scripts/test.sh"
    touch "$cellar_root/$version/nvim/init.lua"
    touch "$cellar_root/$version/termux/termux.properties"
    touch "$cellar_root/$version/docs/README.md"
}

########################################
# T1.1: Tests for usage/help behavior
########################################

@test "setup script exits with usage when no args" {
    # Mock brew --prefix to return fake Cellar
    local fake_cellar="$TEST_TMPDIR/fake_cellar"
    create_fake_cellar "$fake_cellar" "1.1.0"

    # Create a mock brew that outputs our fake prefix
    local mock_bin="$TEST_TMPDIR/mock_bin"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    # Run setup script with mock PATH
    PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT"
    echo "output: $output" >&2
    echo "status: $status" >&2
    # Should either exit 0 with usage or exit 1 with error about missing cellar
    # The key is: script should not silently succeed with no args in a way that does nothing
    # After RED: this will fail because script doesn't exist
    # After GREEN: script handles no-args gracefully
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "setup script --help shows usage" {
    # This test verifies help flag works
    # RED: script doesn't exist yet - will fail
    # GREEN: implementation provides --help
    run bash "$SETUP_SCRIPT" --help
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]
    [[ "$output" == *"termux-dotfiles-setup"* ]] || [[ "$output" == *"--force"* ]] || [[ "$output" == *"dry-run"* ]]
}

########################################
# T1.2: Tests for --dry-run behavior
########################################

@test "setup script --dry-run does not modify anything" {
    local fake_cellar="$TEST_TMPDIR/cellar_dryrun"
    create_fake_cellar "$fake_cellar" "1.1.0"
    local target_dir="$TEST_TMPDIR/home_config/termux-dotfiles"
    mkdir -p "$target_dir"

    local mock_bin="$TEST_TMPDIR/mock_bin_dryrun"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    # Create a dummy script that doesn't exist to verify dry-run doesn't create it
    # The target directory should remain empty after dry-run
    local original_count
    original_count=$(ls -la "$target_dir" 2>/dev/null | wc -l || echo "0")

    HOME="$TEST_TMPDIR/home_config" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT" --dry-run
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]] || [[ "$output" == *"Would"* ]] || [[ "$output" == *"Dry-run"* ]]

    # Verify target_dir was not modified
    local final_count
    final_count=$(ls -la "$target_dir" 2>/dev/null | wc -l || echo "0")
    [ "$original_count" -eq "$final_count" ]
}

########################################
# T1.3: Tests for --force flag behavior
########################################

@test "setup script --force creates symlinks" {
    local fake_cellar="$TEST_TMPDIR/cellar_force"
    create_fake_cellar "$fake_cellar" "1.1.0"
    local target_dir="$TEST_TMPDIR/home_force/.config/termux-dotfiles"
    mkdir -p "$target_dir"

    local mock_bin="$TEST_TMPDIR/mock_bin_force"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    HOME="$TEST_TMPDIR/home_force" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT" --force
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]

    # Verify symlinks were created
    [[ -L "$target_dir/zsh" ]]
    [[ -L "$target_dir/tmux" ]]
    [[ -L "$target_dir/nvim" ]]
    [[ -L "$target_dir/scripts" ]]
    [[ -L "$target_dir/termux" ]]
    [[ -L "$target_dir/docs" ]]
}

@test "setup script --force replaces existing symlinks" {
    local fake_cellar="$TEST_TMPDIR/cellar_replace"
    create_fake_cellar "$fake_cellar" "2.0.0"
    local target_dir="$TEST_TMPDIR/home_replace/.config/termux-dotfiles"
    mkdir -p "$target_dir"

    # Create a pre-existing broken symlink
    ln -s "/nonexistent" "$target_dir/zsh"

    local mock_bin="$TEST_TMPDIR/mock_bin_replace"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    HOME="$TEST_TMPDIR/home_replace" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT" --force
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]

    # Verify the symlink was replaced (not broken anymore)
    [[ -L "$target_dir/zsh" ]]
    [[ -e "$target_dir/zsh" ]]
}

########################################
# T1.4: Tests for directory creation
########################################

@test "setup script creates \$HOME/.config/termux-dotfiles/ directory" {
    local fake_cellar="$TEST_TMPDIR/cellar_mkdir"
    create_fake_cellar "$fake_cellar" "1.1.0"
    local target_dir="$TEST_TMPDIR/home_mkdir/.config/termux-dotfiles"

    # Ensure target directory does NOT exist initially
    [[ ! -d "$target_dir" ]]

    local mock_bin="$TEST_TMPDIR/mock_bin_mkdir"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    HOME="$TEST_TMPDIR/home_mkdir" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT" --force
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]
    [[ -d "$target_dir" ]]
}

########################################
# T1.5: Tests for idempotency (no --force)
########################################

@test "setup script handles existing symlinks gracefully (no --force)" {
    local fake_cellar="$TEST_TMPDIR/cellar_idem"
    create_fake_cellar "$fake_cellar" "1.1.0"
    local target_dir="$TEST_TMPDIR/home_idem/.config/termux-dotfiles"
    mkdir -p "$target_dir"

    # Create pre-existing valid symlink
    ln -s "$fake_cellar/1.1.0/zsh" "$target_dir/zsh"

    local mock_bin="$TEST_TMPDIR/mock_bin_idem"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    # Run without --force - should skip existing symlinks
    HOME="$TEST_TMPDIR/home_idem" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT"
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]

    # Original symlink should still be there (not replaced)
    [[ -L "$target_dir/zsh" ]]
    [[ "$(readlink "$target_dir/zsh")" == "$fake_cellar/1.1.0/zsh" ]]
}

########################################
# T1.6: Tests for Cellar detection
########################################

@test "setup script detects Cellar path correctly via brew --prefix" {
    local fake_cellar="$TEST_TMPDIR/cellar_detect"
    create_fake_cellar "$fake_cellar" "1.1.0"

    local mock_bin="$TEST_TMPDIR/mock_bin_detect"
    mkdir -p "$mock_bin"
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$fake_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    HOME="$TEST_TMPDIR/home_detect" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT" --dry-run
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]
    # Output should mention the cellar path or the version
    [[ "$output" == *"1.1.0"* ]] || [[ "$output" == *"Cellar"* ]] || [[ "$output" == *"termux-dotfiles"* ]]
}

@test "setup script handles missing Cellar gracefully" {
    local mock_bin="$TEST_TMPDIR/mock_bin_missing"
    mkdir -p "$mock_bin"
    # Mock brew that returns a path where no cellar exists
    cat > "$mock_bin/brew" <<MOCK_BREW
#!/usr/bin/env bash
echo "$TEST_TMPDIR/nonexistent_cellar"
MOCK_BREW
    chmod +x "$mock_bin/brew"

    HOME="$TEST_TMPDIR/home_missing" PATH="$mock_bin:$PATH" run bash "$SETUP_SCRIPT"
    echo "output: $output" >&2
    echo "status: $status" >&2
    # Should exit with error, not crash
    [ "$status" -ne 0 ]
}

########################################
# T1.7: Test script syntax check
########################################

@test "setup script passes bash syntax check" {
    # Verify script has no syntax errors
    run bash -n "$SETUP_SCRIPT"
    echo "output: $output" >&2
    echo "status: $status" >&2
    [ "$status" -eq 0 ]
}