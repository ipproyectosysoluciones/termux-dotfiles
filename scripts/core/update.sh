#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/utils/logger.sh"

log "Updating environment..."

log "Updating Termux packages..."

pkg update -y
pkg upgrade -y

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Updating tmux plugins..."

  "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
fi

log "Updating Neovim plugins..."

nvim --headless "+Lazy! sync" +qa

log "Updating Mason registry..."

nvim --headless "+MasonUpdate" +qa

log "Updating dotfiles repository..."

git -C "$HOME/dotfiles" pull

log "Update completed."

