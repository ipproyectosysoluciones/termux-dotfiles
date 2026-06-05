#!/data/data/com.termux/files/usr/bin/bash

# source "$HOME/dotfiles/scripts/ai/providers/claude.sh"

export PATH="/data/data/com.termux/files/usr/bin:$PATH"
export RIPGREP_BINARY="/data/data/com.termux/files/usr/bin/rg"
hash -r

export GEMINI_WORKSPACE="${AI_WORKSPACE:-$PWD}"
export GEMINI_PROJECT="${AI_PROJECT:-default}"
export GEMINI_AGENT="${AI_AGENT:-generic-agent}"
export GEMINI_SKILL="${AI_SKILL:-generic-skill}"

cd "$GEMINI_WORKSPACE" || exit 1

run_gemini() {

    local prompt="$*"

    local output
    local status

    set +e

    output="$(
        gemini \
            --yolo \
            --prompt "$prompt" \
            2>&1
    )"

    local status=$?

    set -e

    echo "$output"

    ########################################
    # QUOTA EXHAUSTED
    ########################################

    if echo "$output" | grep -qi "QUOTA_EXHAUSTED"; then

        echo
        echo "[ai] gemini quota exhausted"
        echo "[ai] falling back to opencode"
        echo

        run_opencode run "$prompt"

        return 0
    fi

    ########################################
    # GENERIC FAILURE
    ########################################

    if [[ $status -ne 0 ]]; then

        echo
        echo "[ai] gemini failed"
        echo "[ai] falling back to gentle"
        echo

        run_gentle "$prompt"

        return 0
    fi

    return 0
}
