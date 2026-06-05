#!/data/data/com.termux/files/usr/bin/bash
# Termux dotfiles shell integration

export DOTFILES_DIR="/data/data/com.termux/files/usr/share/termux-dotfiles"

# Add dotfiles bin to PATH if it exists
if [[ -d "$DOTFILES_DIR/bin" ]]; then
    export PATH="$DOTFILES_DIR/bin:$PATH"
fi