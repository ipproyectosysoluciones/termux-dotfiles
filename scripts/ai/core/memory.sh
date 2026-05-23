#!/data/data/com.termux/files/usr/bin/bash

########################################
# ENGRAM
######################################## 

memory_available() {

    command -v engram >/dev/null 2>&1
}

######################################## 
# PROJECT CONTEXT 
######################################## 

memory_project_context() {

    local project="${1:-}"

    if ! memory_available; then
        return 0
    fi

    if [[ -z "$project" ]]; then
        return 0
    fi

    engram context "$project" 2>/dev/null || true
}

#########################################
# MEMORY SEARCH
######################################### 

memory_search() {

    local query="${1:-}"
    local project="${2:-}"

    if ! memory_available; then
        return 0
    fi

    if [[ -z "$query" ]]; then
        return 0
    fi

    engram search "$query" \
        --project "$project" \
        --limit 5 \
        2>/dev/null || true
}

######################################## 
# MEMORY SAVE
########################################

memory_save() {

    local title="${1:-session}"
    local content="${2:-}"
    local project="${3:-default}"

    if ! memory_available; then
        return 0
    fi

    if [[ -z "$content" ]]; then
        return 0
    fi

    engram save \
        "$title" \
        "$content" \
        --project "$project" \
        --scope project \
        2>/dev/null || true
}

