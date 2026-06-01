#!/data/data/com.termux/files/usr/bin/bash

SYNC_ROOT="$HOME/.ai-sync"

DEBIAN_WORKSPACE_ROOT="/home/dev/workspaces"

########################################
# ENSURE SYNC ROOT
########################################

ensure_sync_root() {

    mkdir -p "$SYNC_ROOT"
}

########################################
# PROJECT SYNC PATH
########################################

sync_project_path() {

    local project="${1:-}"

    echo "$SYNC_ROOT/$project"
}

########################################
# MIRROR PROJECT
########################################

mirror_project() {

    local source="${1:-}"
    local project="${2:-}"

    ensure_sync_root

    local target
    target="$(sync_project_path "$project")"

    mkdir -p "$target"

    rm -rf "$target"/* 2>/dev/null || true

    cp -R \
        "$source/." \
        "$target/" \
        >/dev/null 2>&1 || true
}

########################################
# PROVIDER WORKSPACE
########################################

provider_workspace() {

    local project="${1:-}"

    echo "$DEBIAN_WORKSPACE_ROOT/$project"
}

