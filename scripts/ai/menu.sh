#!/data/data/com.termux/files/usr/bin/bash

source "$HOME/dotfiles/scripts/ai/utils.sh"

clear

banner "AI Workspace Launcher"

CHOICE=$(gum choose \
  "NeoVim" \
  "OpenCode" \
  "Gentle AI" \
  "Engram" \
  "Full Workspace" \
  "Sessions" \
  "Exit"
)

case "$CHOICE" in
  "NeoVim")
    ~/dotfiles/scripts/ai/nvim.sh
    ;;
  "OpenCode")
    ~/dotfiles/scripts/ai/opencode.sh
    ;;
  "Gentle AI")
    ~/dotfiles/scripts/ai/gentle.sh
    ;;
  "Engram")
    ~/dotfiles/scripts/ai/engram.sh
    ;;
  "Full Workspace")
    ~/dotfiles/scripts/ai/workspace.sh
    ;;
  "Sessions")
    ~/dotfiles/scripts/ai/sessions.sh
    ;;
  "Exit")
    exit 0
    ;;
esac

