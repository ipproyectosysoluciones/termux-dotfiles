#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/utils/logger.sh"

# Directorio

BACKUP_DIR="$HOME/dotfiles-backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

DEST="$BACKUP_DIR/$TIMESTAMP"

mkdir -p "$DEST"

# Logs

log "Creating backup..."

# Backup de archivos: zshrc

cp "$HOME/.zshrc" "$DEST/" 2>/dev/null || true

# tmux.conf

cp "$HOME/.tmux.conf" "$DEST/" 2>/dev/null || true

# Backup de carpetas: nvim

cp -r "$HOME/.config/nvim" "$DEST/" 2>/dev/null || true

# zsh

cp -r "$HOME/.config/zsh" "$DEST/" 2>/dev/null || true

# tmux

cp -r "$HOME/.config/tmux" "$DEST/" 2>/dev/null || true

# termux

cp -r "$HOME/.termux" "$DEST/" 2>/dev/null || true

# Archivo metadata opcional

echo "Backup created at: $(date)" > "$DEST/info.txt"

log "Backup completed: $DEST"

