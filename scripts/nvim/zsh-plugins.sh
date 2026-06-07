#!/data/data/com.termux/files/usr/bin/bash

# zsh-plugins.sh — installs ZSH shell plugins (powerlevel10k, autosuggestions,
# syntax-highlighting, fzf-tab, defer, completions) into ~/.zsh-plugins.
#
# NOTE: This script is named `zsh-plugins.sh` (not `plugins.sh`) because it
# installs ZSH plugins, NOT Neovim plugins. Neovim plugins are managed
# entirely by lazy.nvim — see nvim/lua/plugins/* and :Lazy sync inside Neovim.
# Previously this file lived at `scripts/nvim/plugins.sh`; the rename was
# applied in PR #1 of the Neovim-review-update SDD change so the path
# matches the actual behavior.

echo "================================="
echo "Installing ZSH shell plugins..."
echo "================================="

# shellcheck disable=SC1091
source "$(dirname "$0")/../utils/logger.sh"

PLUGINS_DIR="$HOME/.zsh-plugins"

mkdir -p "$PLUGINS_DIR"

clone_plugin() {
    local repo="$1"
    local dir="$2"

    if [[ -d "$PLUGINS_DIR/$dir" ]]; then
        echo "[✓] $dir already installed"
    else
        echo "[+] Installing $dir..."

        git clone --depth=1 \
            "https://github.com/$repo.git" \
            "$PLUGINS_DIR/$dir"
    fi
}

# =========================================
# POWERLEVEL10K
# =========================================

clone_plugin romkatv/powerlevel10k powerlevel10k

# =========================================
# AUTOSUGGESTIONS
# =========================================

clone_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions

# =========================================
# SYNTAX HIGHLIGHTING
# =========================================

clone_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting

# =========================================
# FZF TAB
# =========================================

clone_plugin Aloxaf/fzf-tab fzf-tab

# =========================================
# ZSH DEFER
# =========================================

clone_plugin romkatv/zsh-defer zsh-defer

# =========================================
# COMPLETIONS
# =========================================

clone_plugin zsh-users/zsh-completions zsh-completions

echo
echo "================================="
echo "Plugins installation completed"
echo "================================="

