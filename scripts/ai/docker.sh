#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

SESSION="docker"

# Helper: print docker status
docker_status() {
    echo "╔══════════════════════════════════════╗"
    echo "║         Docker Status               ║"
    echo "╚══════════════════════════════════════╝"
    docker --version 2>/dev/null
    echo ""

    if docker info > /dev/null 2>&1; then
        echo "✅ Daemon: connected"
        echo ""
        docker ps -a 2>/dev/null || true
    else
        echo "⚠️  Daemon: not reachable (expected in proot)"
        echo ""
        echo "Containers require a remote Docker host:"
        echo "  docker context create remote \\"
        echo "    --docker host=tcp://<HOST>:2375"
        echo "  docker context use remote"
        echo ""
        echo "CLI-only: build ✓  pull ✓  push ✓  info ✓"
    fi
    echo ""
    echo "Contexts:"
    docker context ls 2>/dev/null || true
    echo ""
    echo "Type 'exit' to close this session."
}

# Check docker inside proot-distro debian
if command -v proot-distro > /dev/null 2>&1; then
    if proot-distro login debian --bind "$HOME:/termux" --user dev -- command -v docker > /dev/null 2>&1; then
        create_session "$SESSION" \
'proot-distro login debian --bind $HOME:/termux --user dev -- bash -c "
    docker --version 2>/dev/null
    echo \"\"
    if docker info > /dev/null 2>&1; then
        echo \"✅ Daemon: connected\"
        echo \"\"
        docker ps -a 2>/dev/null || true
    else
        echo \"⚠️  Daemon: not reachable (expected in proot)\"
        echo \"\"
        echo \"Containers require a remote Docker host:\"
        echo \"  docker context create remote \\\\"
        echo \"    --docker host=tcp://<HOST>:2375\"
        echo \"  docker context use remote\"
        echo \"\"
        echo \"CLI-only: build ✓  pull ✓  push ✓  info ✓\"
    fi
    echo \"\"
    echo \"Contexts:\"
    docker context ls 2>/dev/null || true
    echo \"\"
    echo \"Type exit to close this session.\"
    exec \"\$SHELL\"
"'

        attach_or_switch "$SESSION"
        exit 0
    fi
fi

# Fallback: native docker
if command -v docker > /dev/null 2>&1; then
    create_session "$SESSION" \
'bash -c "
    docker --version 2>/dev/null
    echo \"\"
    if docker info > /dev/null 2>&1; then
        echo \"✅ Daemon: connected\"
        echo \"\"
        docker ps -a 2>/dev/null || true
    else
        echo \"⚠️  Daemon: not reachable\"
        echo \"\"
        echo \"CLI-only: build ✓  pull ✓  push ✓  info ✓\"
    fi
    exec \"\$SHELL\"
"'

    attach_or_switch "$SESSION"
    exit 0
fi

echo "docker is not installed."
echo "Install: pkg install docker"
exit 1