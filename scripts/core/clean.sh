#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/utils/logger.sh"

log "Cleaning environment..."

# pkg cache

log "Cleaning Termux package cache..."

pkg autoclean -y || true
apt autoremove -y || true

# Neovim swap/cache

log "Cleaning Neovim swap files..."

find "$HOME/.local/state/nvim/swap" \
-type f -delete 2>/dev/null || true

# tmux resurrect

log "Cleaning tmux resurrect cache..."

find "$HOME/.tmux/resurrect" \
-type f -name "*.txt" \
-delete 2>/dev/null || true

# logs temporales

log "Cleaning temporary logs..."

find "$HOME/.cache" \
-type f \
-name "*.log" \
-delete 2>/dev/null || true

# cache general

log "Cleaning cache directories..."

rm -rf "$HOME/.cache/thumbnails" 2>/dev/null || true

log "Cleanup completed."
