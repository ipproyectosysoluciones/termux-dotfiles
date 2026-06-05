#!/data/data/com.termux/files/usr/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/utils/logger.sh"
source "$BASE_DIR/core/install_type.sh"

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

git -C "$HOME/dotfiles" pull 2>/dev/null || true

log "Update completed."

# Version check
check_version() {
  local install_type
  install_type="$(detect_install_type)"
  local version_file

  case "$install_type" in
    package)
      version_file="/data/data/com.termux/files/usr/share/termux-dotfiles/VERSION"
      ;;
    curl)
      version_file="$HOME/dotfiles/VERSION"
      ;;
    *)
      return 0
      ;;
  esac

  if [[ -f "$version_file" ]]; then
    local local_version
    local_version=$(cat "$version_file" | tr -d ' \t\n\r')
    local remote_version
    remote_version=$(git -C "$HOME/dotfiles" ls-remote --tags origin 2>/dev/null | grep -o 'v[0-9.]*' | sort -V | tail -1 | tr -d 'v')
    if [[ -n "$remote_version" ]] && [[ "$remote_version" != "$local_version" ]]; then
      log "Update available: v$remote_version (current: v$local_version)"
      log "Run 'cd ~/dotfiles && git pull' to update"
    fi
  fi
}

# Call at end of update
check_version

