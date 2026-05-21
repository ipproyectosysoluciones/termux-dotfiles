#!/bin/bash

set -euo pipefail

ROOT="$HOME/dotfiles/scripts/debian"

echo "[debian] Installing AI tooling..."

########################################
# GEMINI CLI
########################################

if ! command -v gemini >/dev/null 2>&1; then
    npm install -g @google/gemini-cli
fi

########################################
# CLAUDE CODE
########################################

if ! command -v claude >/dev/null 2>&1; then
    npm install -g @anthropic-ai/claude-code
fi

########################################
# OPENCODE
########################################

if ! command -v opencode >/dev/null 2>&1; then
    bash "$ROOT/bootstrap/opencode.sh"
fi

########################################
# VERIFY
########################################

echo
echo "[debian] Installed AI tools:"
echo

which gemini || true
which claude || true
which opencode || true

echo
echo "[debian] AI tooling installed"
