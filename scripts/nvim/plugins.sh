#!/data/data/com.termux/files/usr/bin/bash

echo "================================="
echo "Installing ZSH plugins..."
echo "================================="

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

