#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup"
DOTFILES_DIR="$HOME/dotfiles"

COMMAND="${1:-}"

show_usage() {
  echo "Usage: repair.sh [COMMAND]"
  echo ""
  echo "Commands:"
  echo "  --check       Check installation health"
  echo "  --backup      Backup user configuration"
  echo "  --restore     Restore from latest backup"
  echo "  --reinstall   Full reinstallation with backup"
  exit 0
}

check_health() {
  local issues=0

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "MISSING: dotfiles directory ($DOTFILES_DIR)"
    issues=$((issues + 1))
  else
    [[ -f "$DOTFILES_DIR/scripts/install.sh" ]] || { echo "MISSING: scripts/install.sh"; issues=$((issues + 1)); }
    [[ -f "$DOTFILES_DIR/scripts/core/update.sh" ]] || { echo "MISSING: scripts/core/update.sh"; issues=$((issues + 1)); }
    [[ -f "$DOTFILES_DIR/VERSION" ]] || { echo "MISSING: VERSION file"; issues=$((issues + 1)); }
  fi

  if [[ $issues -eq 0 ]]; then
    echo "Installation healthy"
    return 0
  else
    echo "Corruption detected: $issues issue(s) found"
    return 1
  fi
}

create_backup() {
  mkdir -p "$BACKUP_DIR"
  local timestamp
  timestamp=$(date +%Y-%m-%d-%H%M%S)
  local backup_file="$BACKUP_DIR/dotfiles-$timestamp.tar.gz"

  if [[ -d "$DOTFILES_DIR" ]]; then
    tar -czf "$backup_file" -C "$HOME" dotfiles/ 2>/dev/null || true
  fi
  if [[ -d "$HOME/.config/nvim" ]]; then
    tar -czf "$backup_file" --append -C "$HOME/.config" nvim/ 2>/dev/null || true
  fi
  if [[ -f "$HOME/.tmux.conf" ]]; then
    tar -czf "$backup_file" --append -C "$HOME" .tmux.conf 2>/dev/null || true
  fi

  echo "Backup created: $backup_file"
}

restore_backup() {
  local latest
  latest=$(ls -t "$BACKUP_DIR"/dotfiles-*.tar.gz 2>/dev/null | head -1)

  if [[ -z "$latest" ]]; then
    echo "Error: No backup found in $BACKUP_DIR" >&2
    exit 1
  fi

  tar -xzf "$latest" -C "$HOME"
  echo "Restored from: $latest"
}

reinstall_dotfiles() {
  echo "Step 1: Creating backup..."
  create_backup

  echo "Step 2: Removing existing installation..."
  rm -rf "$DOTFILES_DIR"

  echo "Step 3: Cloning fresh repository..."
  git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git "$DOTFILES_DIR"

  echo "Step 4: Restoring user configuration..."
  restore_backup

  echo "Step 5: Running installation..."
  bash "$DOTFILES_DIR/scripts/install.sh"

  echo "Reinstallation complete."
}

case "$COMMAND" in
  --check)
    check_health
    ;;
  --backup)
    create_backup
    ;;
  --restore)
    restore_backup
    ;;
  --reinstall)
    reinstall_dotfiles
    ;;
  *)
    show_usage
    ;;
esac