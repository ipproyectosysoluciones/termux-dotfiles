#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/utils/logger.sh"

log "Starting dotfiles installation..."

bash "$BASE_DIR/core/packages.sh"
bash "$BASE_DIR/core/symlinks.sh"
bash "$BASE_DIR/nvim/plugins.sh"
bash "$BASE_DIR/tmux/tmux_plugins.sh"

log "Installation completed."

# Run update to ensure latest versions
log "Running environment update..."
bash "$BASE_DIR/core/update.sh"

log "Update completed."
