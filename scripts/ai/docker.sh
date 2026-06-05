#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="docker"

# Check docker inside proot-distro debian
if command -v proot-distro > /dev/null 2>&1; then
    if proot-distro login debian --bind "$HOME:/termux" --user dev -- command -v docker > /dev/null 2>&1; then
        launch_in_window "$SESSION" \
            "proot-distro login debian --bind $HOME:/termux --user dev" \
            "docker"
        exit 0
    fi
fi

# Fallback: native docker
if command -v docker > /dev/null 2>&1; then
    launch_in_window "$SESSION" "echo 'Docker CLI available' && exec \$SHELL" "docker"
    exit 0
fi

echo "docker is not installed."
echo "Install: pkg install docker"
exit 1
