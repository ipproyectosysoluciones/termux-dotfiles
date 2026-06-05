#!/usr/bin/env bats

load ../test_helper

# Override PROJECT_ROOT: tests are at tests/e2e/ level (two levels deep), need to go up two levels
PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"

@test "install.sh --help shows usage" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  run bash "$install_script" --help
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: install.sh [OPTIONS]"* ]]
  [[ "$output" == *"--version"* ]]
  [[ "$output" == *"--dry-run"* ]]
  [[ "$output" == *"--check"* ]]
  [[ "$output" == *"--force"* ]]
  [[ "$output" == *"--help"* ]]
}

@test "install.sh --dry-run shows what would be installed" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  run bash "$install_script" --dry-run
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would install: dotfiles"* ]]
  [[ "$output" == *"Would run: core/packages.sh"* ]]
  [[ "$output" == *"Dry-run complete. No changes made."* ]]
}

@test "install.sh --check on non-existent installation shows issues" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  # Create a temporary base dir without dotfiles
  local temp_dir="$TEST_TMPDIR/install-check-test"
  mkdir -p "$temp_dir"

  # Mock HOME to temp_dir for this test
  HOME="$temp_dir" run bash "$install_script" --check
  echo "$output" >&2
  [ "$status" -eq 1 ]
  [[ "$output" == *"MISSING: dotfiles directory"* ]]
  [[ "$output" == *"Found"* ]]
  [[ "$output" == *"issue(s)"* ]]
}

@test "install.sh --version flag is accepted" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  # Verify the script doesn't error on --version flag (dry-run mode)
  run bash "$install_script" --version "v1.0.0" --dry-run
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would install: dotfiles"* ]]
}

@test "install.sh unknown option returns error" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  run bash "$install_script" --unknown-flag
  echo "$output" >&2
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
  [[ "$output" == *"Usage: install.sh"* ]]
}

@test "install.sh without --force refuses existing installation" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  # Create existing dotfiles directory
  local temp_dir="$TEST_TMPDIR/install-force-test"
  mkdir -p "$temp_dir/dotfiles"

  # Mock HOME to temp_dir
  HOME="$temp_dir" run bash "$install_script"
  echo "$output" >&2
  [ "$status" -eq 1 ]
  [[ "$output" == *"Existing installation found"* ]]
  [[ "$output" == *"Use --force to overwrite"* ]]
}

@test "install.sh --force proceeds with existing installation" {
  local install_script
  install_script="$(resolve_script "scripts/install.sh")"

  # Create existing dotfiles directory with minimal structure
  local temp_dir="$TEST_TMPDIR/install-force-test"
  mkdir -p "$temp_dir/dotfiles/scripts/core"
  touch "$temp_dir/dotfiles/VERSION"

  # Mock HOME and dotfiles path
  HOME="$temp_dir" DOTFILES="$temp_dir/dotfiles" run bash "$install_script" --force --dry-run
  echo "$output" >&2
  [ "$status" -eq 0 ]
}