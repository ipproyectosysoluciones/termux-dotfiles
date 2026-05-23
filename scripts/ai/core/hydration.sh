#!/data/data/com.termux/files/usr/bin/bash

########################################
# BUILD CONTEXT
########################################

build_context() {

    local prompt="${1:-}"

    local memory=""
    local project=""
    local branch=""

    ########################################
    # MEMORY SEARCH
    ########################################

    memory="$(
        memory_search "$prompt" \
        | head -n 20
    )"

    ########################################
    # PROJECT
    ########################################

    project="$PROJECT_NAME"
    
    local provider_root=""

    provider_root="$(
        provider_workspace "$PROJECT_NAME"
    )"

    ########################################
    # BRANCH
    ########################################

    branch="$GIT_BRANCH"

    ########################################
    # OUTPUT
    ########################################

    cat <<EOF
Project: $project
Project root: $provider_root
Branch: $branch

Relevant memory:
$memory

User request:
$prompt
EOF
}

