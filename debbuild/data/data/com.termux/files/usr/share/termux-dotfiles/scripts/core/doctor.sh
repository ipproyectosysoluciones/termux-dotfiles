#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/utils/logger.sh"

log "Running environment diagnostics..."

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "[✓] $1 installed"
  else
    echo "[✗] $1 missing"
  fi
}

check_command git
check_command zsh
check_command tmux
check_command nvim
check_command rg
check_command fd
check_command node

check_symlink() {
  if [ -L "$1" ]; then
    echo "[✓] Symlink exists: $1"
  else
    echo "[✗] Missing symlink: $1"
  fi
}

check_symlink "$HOME/.zshrc"
check_symlink "$HOME/.tmux.conf"
check_symlink "$HOME/.config/nvim"

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "[✓] TPM installed"
else
  echo "[✗] TPM missing"
fi

if [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  echo "[✓] lazy.nvim installed"
else
  echo "[✗] lazy.nvim missing"
fi

log "Diagnostics completed."
