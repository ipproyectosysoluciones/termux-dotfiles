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


##################################################
# RUN GENTLE (PROVIDER INTERFACE)
##################################################

run_gentle() {

    local prompt="$*"

    if ! command -v gentle-ai >/dev/null 2>&1; then
        echo "[ai] gentle-ai unavailable"
        echo "[ai] no providers available for: $prompt"
        return 1
    fi

    echo "[ai] gentle-ai :: control-plane orchestrator"
    echo "[ai] managing agents, skills, and fallback orchestration"
    echo

    ########################################
    # HEALTH CHECK
    ########################################

    gentle-ai doctor >/dev/null 2>&1
    local doctor_status=$?

    if [[ $doctor_status -ne 0 ]]; then
        echo "[ai] gentle-ai health check failed"
        echo "[ai] run gentle-ai doctor for details"
        echo
    fi

    ########################################
    # LAST RESORT: TRY OPENCODE
    ########################################

    if command -v opencode >/dev/null 2>&1; then

        echo "[ai] last resort: trying opencode"
        echo

        run_opencode run "$prompt"
        local opencode_status=$?

        if [[ $opencode_status -eq 0 ]]; then
            return 0
        fi

        echo
        echo "[ai] opencode also failed"
        echo
    fi

    ########################################
    # ALL PROVIDERS EXHAUSTED
    ########################################

    echo "[ai] all AI providers exhausted (gemini → opencode → gentle)"
    echo "[ai] install an AI provider to process queries"
    echo

    if command -v memory_save >/dev/null 2>&1; then
        memory_save "system" "All providers exhausted for prompt: ${prompt:0:80}"
    fi

    return 1
}
