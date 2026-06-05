#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Defaults
TARGET_VERSION=""
DRY_RUN=false
CHECK_MODE=false
FORCE=false

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      TARGET_VERSION="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --check)
      CHECK_MODE=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help)
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --version <tag>  Pin installation to a specific version (default: latest main)"
      echo "  --dry-run        Show what would be installed without making changes"
      echo "  --check          Verify existing installation health"
      echo "  --force          Overwrite existing installation without prompting"
      echo "  --help           Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: install.sh [--version <tag>] [--dry-run] [--check] [--force] [--help]"
      exit 1
      ;;
  esac
done

# Dry-run mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "Would install: dotfiles to $HOME/dotfiles"
  echo "Would run: core/packages.sh, core/symlinks.sh, nvim/plugins.sh, tmux/tmux_plugins.sh"
  echo "Would run: core/update.sh"
  echo "Dry-run complete. No changes made."
  exit 0
fi

# Check mode
if [[ "$CHECK_MODE" == "true" ]]; then
  if [[ -f "$BASE_DIR/repair.sh" ]]; then
    bash "$BASE_DIR/repair.sh" --check
    exit $?
  else
    echo "Checking installation..."
    issues=0
    [[ -d "$HOME/dotfiles" ]] || { echo "Missing: dotfiles directory"; issues=$((issues+1)); }
    [[ -f "$HOME/dotfiles/scripts/install.sh" ]] || { echo "Missing: install.sh"; issues=$((issues+1)); }
    [[ -f "$HOME/dotfiles/scripts/core/update.sh" ]] || { echo "Missing: update.sh"; issues=$((issues+1)); }
    if [[ $issues -eq 0 ]]; then
      echo "Installation healthy"
      exit 0
    else
      echo "Found $issues issue(s)"
      exit 1
    fi
  fi
  exit 0
fi

source "$BASE_DIR/utils/logger.sh"

# Force check
if [[ "$FORCE" != "true" ]] && [[ -d "$HOME/dotfiles" ]]; then
  echo "Existing installation found at $HOME/dotfiles"
  echo "Use --force to overwrite, or run repair.sh --reinstall to reinstall safely"
  exit 1
fi

log "Starting dotfiles installation..."

# Version pinning
if [[ -n "$TARGET_VERSION" ]]; then
  log "Installing version: $TARGET_VERSION"
  git clone --branch "$TARGET_VERSION" https://github.com/ipproyectosysoluciones/termux-dotfiles.git "$HOME/dotfiles"
else
  git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git "$HOME/dotfiles"
fi

cd "$HOME/dotfiles"

bash "$BASE_DIR/core/packages.sh"
bash "$BASE_DIR/core/symlinks.sh"
bash "$BASE_DIR/nvim/plugins.sh"
bash "$BASE_DIR/tmux/tmux_plugins.sh"

log "Installation completed."

# Run update to ensure latest versions
log "Running environment update..."
bash "$BASE_DIR/core/update.sh"

log "Update completed."