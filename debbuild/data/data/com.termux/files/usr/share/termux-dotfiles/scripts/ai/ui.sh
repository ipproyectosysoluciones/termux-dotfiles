#!/data/data/com.termux/files/usr/bin/bash

banner() {
    if command -v gum > /dev/null 2>&1; then
        gum style \
            --foreground 39 \
            --border foreground \
            --border rounded \
            --padding "1 2" \
            --margin "1 0" \
            "$1"
    else
        echo "═══════════════════════════════"
        echo "  $1"
        echo "═══════════════════════════════"
    fi
}

section() {
    if command -v gum > /dev/null 2>&1; then
        gum style \
            --foreground 212 \
            --bold \
            "$1"
    else
        echo "── $1 ──"
    fi
}

success() {
    if command -v gum > /dev/null 2>&1; then
        gum style \
            --foreground 42 \
            "✔ $1"
    else
        echo "✓ $1"
    fi
}

error() {
    if command -v gum > /dev/null 2>&1; then
        gum style \
            --foreground 196 \
            "✘ $1"
    else
        echo "✗ $1"
    fi
}
