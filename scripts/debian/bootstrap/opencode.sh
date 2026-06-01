#!/usr/bin/env bash

set -euo pipefail

echo "[debian] Installing OpenCode..."

########################################
# INSTALL
########################################

curl -fsSL https://opencode.ai/install | bash

########################################
# PATH
########################################

export PATH="$HOME/.local/bin:$PATH"

########################################
# VALIDATION
########################################

if command -v opencode >/dev/null 2>&1; then

    echo
    echo "[debian] OpenCode installed:"
    echo

    which opencode
    opencode --version || true

else
    echo
    echo "[debian] OpenCode installation failed"
    exit 1
fi

########################################
# DEV USER ZSHENV
########################################

DEV_ZSENV="/home/dev/.zshenv"

if [ -f "$DEV_ZSENV" ] && ! grep -q '.opencode/bin' "$DEV_ZSENV" 2>/dev/null; then

    echo "" >> "$DEV_ZSENV"
    echo "# opencode" >> "$DEV_ZSENV"
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$DEV_ZSENV"

    echo "[debian] OpenCode PATH added to $DEV_ZSENV"

fi

