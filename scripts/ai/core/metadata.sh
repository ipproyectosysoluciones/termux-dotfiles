#!/data/data/com.termux/files/usr/bin/bash

WORKSPACE_META_DIR=".ai"

WORKSPACE_META_FILE="workspace.env"

load_workspace_metadata() {

    local metadata_path

    metadata_path="$PROJECT_ROOT/$WORKSPACE_META_DIR/$WORKSPACE_META_FILE"

    [[ -f "$metadata_path" ]] || return 1

    source "$metadata_path"
}

ensure_workspace_metadata() {

    local metadata_dir
    local metadata_path

    metadata_dir="$PROJECT_ROOT/$WORKSPACE_META_DIR"

    metadata_path="$metadata_dir/$WORKSPACE_META_FILE"

    mkdir -p "$metadata_dir"

    if [[ ! -f "$metadata_path" ]]; then

        cat > "$metadata_path" <<EOF
PROVIDER=
LAYOUT=
AUTO_START=
RUNTIME=
EOF
    fi
}

