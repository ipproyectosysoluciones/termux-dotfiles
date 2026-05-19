#!/data/data/com.termux/files/usr/bin/bash

banner() {
    gum style \
        --foreground 39 \
        --border foreground \
        --border rounded \
        --padding "1 2" \
        --margin "1 0" \
        "$1"
}

section() {
    gum style \
        --foreground 212 \
        --bold \
        "$1"
}

success() {
    gum style \
        --foreground 42 \
        "✔ $1"
}

error() {
    gum style \
        --foreground 196 \
        "✘ $1"
}
