#!/bin/bash

set -euo pipefail

echo "[debian] Installing AI tooling..."

########################################
# GEMINI CLI
########################################

npm install -g @google/gemini-cli

########################################
# CLAUDE CODE
########################################

npm install -g @anthropic-ai/claude-code

########################################
# OPENCODE
########################################

# Ajustar nombre real luego
# npm install -g opencode-ai

########################################
# VERIFY
########################################

echo
echo "[debian] Installed AI tools:"
echo

which gemini || true
which claude || true

echo
echo "[debian] AI tooling installed"

