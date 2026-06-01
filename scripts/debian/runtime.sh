#!/data/data/com.termux/files/usr/bin/bash

# Runtime setup script - Initialize Debian runtime environment
# Configures PATH and environment for the session

set -e

echo "========================================"
echo "Debian Runtime Setup"
echo "========================================"

# Add common binary directories to PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Configure Git identity if not set
if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    echo "Git user email not configured. Run: git config --global user.email 'your@email.com'"
fi

# Ensure .local directories exist
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share"

# Load dotfiles environment if available
if [[ -f "$HOME/dotfiles/scripts/core/env.sh" ]]; then
    source "$HOME/dotfiles/scripts/core/env.sh"
fi

echo -e "\033[0;32m[✓]\033[0m Runtime environment initialized"
echo "PATH=$PATH"