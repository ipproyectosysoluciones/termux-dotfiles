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

########################################
# DEV USER ZSH CONFIG (via bind mount)
########################################

DOTFILES_ZSH="/termux/dotfiles/zsh"
CONFIG_DIR="/home/dev/.config/zsh"

if [ -d "$DOTFILES_ZSH" ] && [ ! -f "$CONFIG_DIR/.zshrc" ]; then

    mkdir -p "$CONFIG_DIR"

    # Symlink each module so .zshrc can source ~/.config/zsh/*.zsh
    for module in exports history plugins aliases functions ssh tmux p10k; do
        if [ -f "$DOTFILES_ZSH/${module}.zsh" ]; then
            ln -sf "$DOTFILES_ZSH/${module}.zsh" "$CONFIG_DIR/${module}.zsh"
            echo "[debian]   linked $module.zsh"
        fi
    done

    # Create .zshrc that mirrors Termux structure
    cat > "$CONFIG_DIR/.zshrc" << 'ZSHRC'
source ~/.config/zsh/exports.zsh
source ~/.config/zsh/history.zsh
source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/ssh.zsh
source ~/.config/zsh/tmux.zsh
source ~/.config/zsh/p10k.zsh
ZSHRC

    echo "[debian] zsh config initialized from Termux dotfiles"
    echo "[debian] ZDOTDIR=$CONFIG_DIR/.zshrc"

fi

