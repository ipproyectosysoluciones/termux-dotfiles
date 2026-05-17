#!/data/data/com.termux/files/usr/bin/bash

echo
echo "================================="
echo " TERMUX DOTFILES INSTALLER"
echo "================================="
echo

DOTFILES="$HOME/dotfiles"

# =========================================
# VALIDATIONS
# =========================================

if [[ ! -d "$DOTFILES" ]]; then
    echo "[!] Dotfiles directory not found:"
    echo "$DOTFILES"
    exit 1
fi

# =========================================
# PACKAGES
# =========================================

echo
echo "[1/3] Installing packages..."
echo

bash "$DOTFILES/scripts/packages.sh"

# =========================================
# SYMLINKS
# =========================================

echo
echo "[2/3] Creating symlinks..."
echo

bash "$DOTFILES/scripts/symlinks.sh"

# =========================================
# TERMUX STORAGE
# =========================================

echo
echo "[3/3] Configuring storage..."
echo

if [[ ! -d "$HOME/storage" ]]; then
    termux-setup-storage
fi

echo
echo "================================="
echo " INSTALLATION COMPLETED"
echo "================================="
echo

echo "Now run:"
echo
echo "exec zsh"
echo
