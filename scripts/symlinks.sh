#!/data/data/com.termux/files/usr/bin/bash

echo "================================="
echo "Creating symbolic links..."
echo "================================="

DOTFILES="$HOME/dotfiles"

mkdir -p "$HOME/.config"

create_link() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        echo "[✓] Symlink already exists: $target"

    elif [[ -e "$target" ]]; then
        echo "[!] Backing up existing: $target"
        mv "$target" "${target}.backup"

        ln -s "$source" "$target"

        echo "[+] Linked: $target"

    else
        ln -s "$source" "$target"

        echo "[+] Linked: $target"
    fi
}

# =========================================
# ZSH
# =========================================

create_link "$DOTFILES/zsh" "$HOME/.config/zsh"

# =========================================
# TMUX
# =========================================

create_link "$DOTFILES/tmux" "$HOME/.config/tmux"

# =========================================
# TERMUX
# =========================================

create_link "$DOTFILES/termux" "$HOME/.config/termux"

# =========================================
# ROOT SYMLINKS
# =========================================

create_link "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

create_link "$HOME/.config/termux/termux.properties" "$HOME/.termux/termux.properties"

create_link "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"

# =========================================
# NVIM
# =========================================

create_link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo
echo "================================="
echo "Symlinks completed"
echo "================================="

