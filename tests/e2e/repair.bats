#!/usr/bin/env bats

load ../test_helper

# Override PROJECT_ROOT: tests are at tests/e2e/ level (two levels deep), need to go up two levels
PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"

setup() {
  export HOME=$(mktemp -d)
  export DOTFILES_DIR="$HOME/dotfiles"
  export BACKUP_DIR="$HOME/.dotfiles-backup"
}

teardown() {
  rm -rf "$HOME"
}

@test "repair.sh --help shows usage" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  run bash "$repair_script" --help
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: repair.sh [COMMAND]"* ]]
  [[ "$output" == *"--check"* ]]
  [[ "$output" == *"--backup"* ]]
  [[ "$output" == *"--restore"* ]]
  [[ "$output" == *"--reinstall"* ]]
}

@test "repair.sh --check on non-existent installation exits non-zero" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  run bash "$repair_script" --check
  echo "$output" >&2
  [ "$status" -ne 0 ]
  [[ "$output" == *"MISSING: dotfiles directory"* ]]
  [[ "$output" == *"Corruption detected"* ]]
}

@test "repair.sh --check on healthy installation exits zero" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  # Create minimal healthy dotfiles structure
  mkdir -p "$DOTFILES_DIR/scripts/core"
  touch "$DOTFILES_DIR/scripts/install.sh"
  touch "$DOTFILES_DIR/scripts/core/update.sh"
  touch "$DOTFILES_DIR/VERSION"

  run bash "$repair_script" --check
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installation healthy"* ]]
}

@test "repair.sh --check reports missing files" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  # Create dotfiles dir but missing files
  mkdir -p "$DOTFILES_DIR"

  run bash "$repair_script" --check
  echo "$output" >&2
  [ "$status" -ne 0 ]
  [[ "$output" == *"MISSING: scripts/install.sh"* ]]
  [[ "$output" == *"MISSING: scripts/core/update.sh"* ]]
  [[ "$output" == *"MISSING: VERSION file"* ]]
}

@test "repair.sh --backup creates backup directory" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  run bash "$repair_script" --backup
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Backup created:"* ]]
  [[ -d "$BACKUP_DIR" ]]
}

@test "repair.sh --backup creates tarball when dotfiles exists" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  # Create dotfiles directory
  mkdir -p "$DOTFILES_DIR/scripts/core"
  touch "$DOTFILES_DIR/VERSION"

  run bash "$repair_script" --backup
  echo "$output" >&2
  [ "$status" -eq 0 ]

  # Check that a backup file was created
  local backup_file
  backup_file=$(ls -t "$BACKUP_DIR"/dotfiles-*.tar.gz 2>/dev/null | head -1)
  [[ -n "$backup_file" ]]
  [[ -f "$backup_file" ]]
}

@test "repair.sh --restore without backup exits with error" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  # Ensure backup dir exists but is empty
  mkdir -p "$BACKUP_DIR"

  run bash "$repair_script" --restore
  echo "$output" >&2
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: No backup found"* ]]
}

@test "repair.sh --restore with backup extracts files" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  # Create a backup manually
  mkdir -p "$BACKUP_DIR"
  local timestamp="2024-01-01-000000"
  local backup_file="$BACKUP_DIR/dotfiles-$timestamp.tar.gz"

  # Create some content to backup
  mkdir -p "$HOME/dotfiles"
  echo "test content" > "$HOME/dotfiles/testfile"

  # Create tarball
  tar -czf "$backup_file" -C "$HOME" dotfiles/

  # Remove original
  rm -rf "$HOME/dotfiles"

  run bash "$repair_script" --restore
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Restored from:"* ]]
  [[ -f "$HOME/dotfiles/testfile" ]]
}

@test "repair.sh no command shows usage" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  run bash "$repair_script"
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: repair.sh [COMMAND]"* ]]
}

@test "repair.sh unknown command shows usage" {
  local repair_script="$PROJECT_ROOT/scripts/repair.sh"

  run bash "$repair_script" --unknown-command
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: repair.sh [COMMAND]"* ]]
}