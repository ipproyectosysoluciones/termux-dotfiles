#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

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
    "$SCRIPT_DIR/nvim.sh"
    ;;
  "OpenCode")
    "$SCRIPT_DIR/opencode.sh"
    ;;
  "Gentle AI")
    "$SCRIPT_DIR/gentle.sh"
    ;;
  "Engram")
    "$SCRIPT_DIR/engram.sh"
    ;;
  "Full Workspace")
    "$SCRIPT_DIR/workspace.sh"
    ;;
  "Sessions")
    "$SCRIPT_DIR/sessions.sh"
    ;;
  "Exit")
    exit 0
    ;;
esac

