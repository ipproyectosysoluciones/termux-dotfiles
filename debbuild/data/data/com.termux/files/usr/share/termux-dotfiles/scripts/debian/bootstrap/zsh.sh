#!/bin/bash

set -euo pipefail

USERNAME="dev"
USER_HOME="/home/$USERNAME"

echo "[debian] Configuring ZSH runtime..."

########################################
# CREATE SYMLINKS
########################################

ln -sf /termux/dotfiles/zsh/zshrc \
"$USER_HOME/.zshrc"

mkdir -p "$USER_HOME/.config"

ln -sf /termux/dotfiles/zsh \
"$USER_HOME/.config/zsh"

########################################
# SET DEFAULT SHELL
########################################

chsh -s /usr/bin/zsh "$USERNAME" || true

########################################
# OWNERSHIP
########################################

chown -R "$USERNAME:$USERNAME" \
"$USER_HOME"

########################################
# VERIFY
########################################

echo
echo "[debian] ZSH runtime configured"

echo
ls -la "$USER_HOME"

