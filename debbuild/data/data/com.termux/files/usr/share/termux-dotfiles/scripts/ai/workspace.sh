#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="workspace"
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/Projects}"

launch_in_window "$SESSION" "cd $WORKSPACE_DIR && pwd && ls -la" "workspace"
