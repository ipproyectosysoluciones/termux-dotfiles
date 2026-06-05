#!/data/data/com.termux/files/usr/bin/bash

detect_project() {
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do

        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return
        fi

        if [[ -f "$dir/package.json" ]]; then
            echo "$dir"
            return
        fi

        if [[ -f "$dir/docker-compose.yml" ]]; then
            echo "$dir"
            return
        fi

        if [[ -f "$dir/Cargo.toml" ]]; then
            echo "$dir"
            return
        fi

        if [[ -f "$dir/requirements.txt" ]]; then
            echo "$dir"
            return
        fi

        dir="$(dirname "$dir")"
    done

    echo "$PWD"
}

project_name() {
    basename "$1"
}

project_type() {

    local dir="$1"

    if [[ -f "$dir/package.json" ]]; then
        echo "node"
        return
    fi

    if [[ -f "$dir/Cargo.toml" ]]; then
        echo "rust"
        return
    fi

    if [[ -f "$dir/requirements.txt" ]]; then
        echo "python"
        return
    fi

    if [[ -f "$dir/docker-compose.yml" ]]; then
        echo "docker"
        return
    fi

    echo "generic"
}

git_branch() {

    local dir="$1"

    git -C "$dir" rev-parse \
        --abbrev-ref HEAD 2>/dev/null \
        || echo "no-git"
}

