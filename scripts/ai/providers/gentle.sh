#!/data/data/com.termux/files/usr/bin/bash

##################################################
# GENTLE CONTROL PLANE
##################################################

gentle_sync() {

    if ! command -v gentle-ai >/dev/null 2>&1; then
        echo "[ai] gentle-ai unavailable"
        return 1
    fi

    gentle-ai sync
}

gentle_upgrade() {

    if ! command -v gentle-ai >/dev/null 2>&1; then
        echo "[ai] gentle-ai unavailable"
        return 1
    fi

    gentle-ai upgrade
}

gentle_refresh_skills() {

    if ! command -v gentle-ai >/dev/null 2>&1; then
        echo "[ai] gentle-ai unavailable"
        return 1
    fi

    gentle-ai skill-registry refresh
}

