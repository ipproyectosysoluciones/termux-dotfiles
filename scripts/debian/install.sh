#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$HOME/dotfiles/scripts/utils/logger.sh"

log "Starting Debian runtime installation..."

########################################
# VALIDATIONS
########################################

command -v proot-distro >/dev/null || {
  echo "[ERROR] proot-distro is not installed"
  exit 1
}

########################################
# INSTALL DEBIAN
########################################

if proot-distro login debian -- true >/dev/null 2>&1; then
  log "Debian already installed"
else
  log "Installing Debian..."
  proot-distro install debian
fi

########################################
# VERIFY DEBIAN
########################################

if ! proot-distro login debian -- true >/dev/null 2>&1; then
  echo "[ERROR] Debian failed to start"
  exit 1
fi

########################################
# EXECUTE BOOTSTRAP
########################################

log "Running bootstrap/base.sh..."

proot-distro login debian --shared-tmp --bind "$HOME:/termux" -- \
    bash < "$BASE_DIR/bootstrap/base.sh"

log "Running bootstrap/ai.sh..."

proot-distro login debian --shared-tmp --bind "$HOME:/termux" -- \
    bash < "$BASE_DIR/bootstrap/ai.sh"

log "Debian runtime installation completed"
