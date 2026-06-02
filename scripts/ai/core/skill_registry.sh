#!/data/data/com.termux/files/usr/bin/bash

load_skill_registry() {

    local registry_file="${SKILL_REGISTRY_FILE:-$HOME/.atl/skill-registry.md}"

    if [[ ! -f "$registry_file" ]]; then
        return 1
    fi

    cat "$registry_file"
}

skill_exists() {

    local skill="${1:-}"
    local registry_file="${SKILL_REGISTRY_FILE:-$HOME/.atl/skill-registry.md}"

    if [[ -z "$skill" ]]; then
        return 1
    fi

    if [[ ! -f "$registry_file" ]]; then
        return 1
    fi

    grep -qi "$skill" "$registry_file"
}

list_skills() {

    local registry_file="${SKILL_REGISTRY_FILE:-$HOME/.atl/skill-registry.md}"

    if [[ ! -f "$registry_file" ]]; then
        return 1
    fi

    grep '^## ' "$registry_file" \
        | sed 's/^## //'
}