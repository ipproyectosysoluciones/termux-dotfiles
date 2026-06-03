#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# Detect available menu tool: prefer gum, fallback to bash select
detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

clear

banner "AI Workspace Launcher"

MENU_TOOL=$(detect_menu_tool)

case "$MENU_TOOL" in
  "gum")
    CHOICE=$(gum choose \
      "NeoVim" \
      "OpenCode" \
      "Gentle AI" \
      "Engram" \
      "Full Workspace" \
      "Sessions" \
      "Exit"
    )
    ;;
  "select")
    echo "Note: gum is recommended for best experience" >&2
    select CHOICE in NeoVim OpenCode "Gentle AI" Engram "Full Workspace" Sessions Exit; do
      [ -n "$CHOICE" ] && break
    done
    ;;
esac

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

