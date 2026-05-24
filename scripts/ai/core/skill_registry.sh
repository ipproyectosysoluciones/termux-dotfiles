#!/data/data/com.termux/files/usr/bin/bash

SKILL_REGISTRY_FILE="$HOME/.atl/skill-registry.md"

load_skill_registry() {

    if [[ ! -f "$SKILL_REGISTRY_FILE" ]]; then
        return 1
    fi

    cat "$SKILL_REGISTRY_FILE"
}

skill_exists() {

    local skill="${1:-}"

    if [[ -z "$skill" ]]; then
        return 1
    fi

    grep -qi "$skill" "$SKILL_REGISTRY_FILE"
}

list_skills() {

    if [[ ! -f "$SKILL_REGISTRY_FILE" ]]; then
        return
    fi

    grep '^## ' "$SKILL_REGISTRY_FILE" \
        | sed 's/^## //'
}

