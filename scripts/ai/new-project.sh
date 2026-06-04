#!/data/data/com.termux/files/usr/bin/bash

# =============================================================================
# new-project.sh - New Project Submenu
# =============================================================================
# Shows a submenu for creating new MEAN or MERN stack projects

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/ui.sh"

# Detect available menu tool: prefer gum, fallback to bash select
detect_menu_tool() {
  if command -v gum > /dev/null 2>&1; then
    echo "gum"
  else
    echo "select"
  fi
}

clear

banner "New Project"

MENU_TOOL=$(detect_menu_tool)

echo "Select project type:"
echo ""

case "$MENU_TOOL" in
  "gum")
    CHOICE=$(gum choose \
      "MEAN Full Stack" \
      "MERN Full Stack" \
      "MEAN Frontend Only" \
      "MERN Frontend Only" \
      "MEAN Backend Only" \
      "MERN Backend Only" \
      "Back"
    )
    ;;
  "select")
    echo "Note: gum is recommended for best experience" >&2
    select CHOICE in "MEAN Full Stack" "MERN Full Stack" "MEAN Frontend Only" "MERN Frontend Only" "MEAN Backend Only" "MERN Backend Only" "Back"; do
      [ -n "$CHOICE" ] && break
    done
    ;;
esac

case "$CHOICE" in
  "MEAN Full Stack")
    "$SCRIPT_DIR/new-mean.sh" --scope full-stack --docker false
    ;;
  "MERN Full Stack")
    "$SCRIPT_DIR/new-mern.sh" --scope full-stack --docker false
    ;;
  "MEAN Frontend Only")
    "$SCRIPT_DIR/new-mean.sh" --scope frontend-only --docker false
    ;;
  "MERN Frontend Only")
    "$SCRIPT_DIR/new-mern.sh" --scope frontend-only --docker false
    ;;
  "MEAN Backend Only")
    "$SCRIPT_DIR/new-mean.sh" --scope backend-only --docker false
    ;;
  "MERN Backend Only")
    "$SCRIPT_DIR/new-mern.sh" --scope backend-only --docker false
    ;;
  "Back"|"")
    echo "Returning to main menu..."
    exit 0
    ;;
esac
