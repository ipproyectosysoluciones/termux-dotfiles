#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

if ! command -v docker > /dev/null 2>&1; then
    echo "docker is not installed."
    echo "Install: pkg install docker"
    exit 1
fi

SESSION="docker"

create_session "$SESSION" \
"docker ps"

attach_or_switch "$SESSION"
