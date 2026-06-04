#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="docker"

# PROOT_DISTRO_BLOCK
# Check if proot-distro login debian works
if command -v proot-distro > /dev/null 2>&1; then
    # DOCKER_CHECK_BLOCK
    # Try to use docker from inside proot-distro debian
    if proot-distro login debian --bind "$HOME:/termux" --user dev -- command -v docker > /dev/null 2>&1; then
        # Docker binary found inside debian - use proot-distro
        create_session "$SESSION" \
            "proot-distro login debian --bind $HOME:/termux --user dev -- docker ps"

        attach_or_switch "$SESSION"
        exit 0
    fi
fi

# Fallback: check native docker
if command -v docker > /dev/null 2>&1; then
    SESSION="docker"

    create_session "$SESSION" \
        "docker ps"

    attach_or_switch "$SESSION"
    exit 0
fi

echo "docker is not installed."
echo "Install: pkg install docker"
exit 1