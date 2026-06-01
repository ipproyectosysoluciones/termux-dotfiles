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

export PATH="$HOME/.opencode/bin:$PATH"

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
# DEV USER ZSH PLUGINS
########################################

ZSH_PLUGINS="/home/dev/.zsh-plugins"

if [ ! -d "$ZSH_PLUGINS" ]; then

    echo "[debian] Installing zsh plugins..."

    apt-get install -y git zoxide >/dev/null 2>&1

    mkdir -p "$ZSH_PLUGINS"

    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$ZSH_PLUGINS/powerlevel10k" 2>/dev/null
    git clone --depth 1 https://github.com/romkatv/zsh-defer.git "$ZSH_PLUGINS/zsh-defer" 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS/zsh-autosuggestions" 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS/zsh-syntax-highlighting" 2>/dev/null
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab.git "$ZSH_PLUGINS/fzf-tab" 2>/dev/null
    git clone --depth 1 https://github.com/zsh-users/zsh-completions.git "$ZSH_PLUGINS/zsh-completions" 2>/dev/null

    chown -R dev:dev "$ZSH_PLUGINS"

    # Copy p10k config from Termux (via bind mount)
    if [ -f "/termux/.p10k.zsh" ]; then
        cp "/termux/.p10k.zsh" "/home/dev/.p10k.zsh"
        chown dev:dev "/home/dev/.p10k.zsh"
        echo "[debian]   p10k config copied"
    fi

    echo "[debian] zsh plugins installed ($ZSH_PLUGINS)"

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

    # Copy each module (not symlink) so it works without bind mount
    for module in exports history plugins aliases functions ssh tmux p10k; do
        if [ -f "$DOTFILES_ZSH/${module}.zsh" ]; then
            cp "$DOTFILES_ZSH/${module}.zsh" "$CONFIG_DIR/${module}.zsh"
            echo "[debian]   copied $module.zsh"
        fi
    done

    # Create .zshrc that mirrors Termux structure with graceful fallbacks
    cat > "$CONFIG_DIR/.zshrc" << 'ZSHRC'
# Load modules with graceful fallback
for module in exports history aliases functions; do
    [ -f "$HOME/.config/zsh/${module}.zsh" ] && source "$HOME/.config/zsh/${module}.zsh"
done

# Plugins (warn if missing, don't break)
if [ -f "$HOME/.config/zsh/plugins.zsh" ]; then
    source "$HOME/.config/zsh/plugins.zsh" 2>/dev/null || echo "[zsh] some plugins unavailable in Debian" >&2
fi

# SSH agent (optional)
[ -f "$HOME/.config/zsh/ssh.zsh" ] && source "$HOME/.config/zsh/ssh.zsh" 2>/dev/null

# tmux (only in interactive terminals)
[ -f "$HOME/.config/zsh/tmux.zsh" ] && source "$HOME/.config/zsh/tmux.zsh" 2>/dev/null

# Powerlevel10k prompt (optional)
if [ -f "$HOME/.config/zsh/p10k.zsh" ] && [ -f "$HOME/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "$HOME/.config/zsh/p10k.zsh"
else
    # Basic prompt when p10k unavailable
    autoload -Uz promptinit && promptinit && prompt adam1
fi
ZSHRC

    # Fix ownership (bootstrap runs as root)
    chown -R dev:dev "$CONFIG_DIR"
    chown dev:dev "$(dirname "$CONFIG_DIR")"

    echo "[debian] zsh config initialized from Termux dotfiles"
    echo "[debian] ZDOTDIR=$CONFIG_DIR/.zshrc"

fi

