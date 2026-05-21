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

