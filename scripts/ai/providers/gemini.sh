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
        echo "$prompt" | timeout 120 gemini \
            --yolo \
            --prompt "$prompt" \
            2>&1
    )"

    local status=$?
    set -e

    ########################################
    # Nested tmux output redirect
    ########################################

    if [[ -n "$TMUX" ]]; then
        echo "[debug] gemini response captured"
    fi

    ########################################
    # FAILURE BRANCH: timeout / quota / error
    ########################################

    if [[ $status -ne 0 ]]; then

        echo "$output"

        local reason
        # Prioritize: timeout > quota > generic
        if [[ $status -eq 124 ]]; then
            reason="gemini timed out"
        elif echo "$output" | grep -qiE "QUOTA_EXHAUSTED|cannot process"; then
            reason="gemini quota exhausted"
        else
            reason="gemini failed (exit $status)"
        fi

        echo
        echo "[ai] $reason"
        echo "[ai] falling back to opencode"
        echo

        run_opencode run "$prompt"
        local fb_status=$?

        if [[ $fb_status -ne 0 ]]; then
            echo
            echo "[ai] opencode also failed"
            echo "[ai] falling back to gentle (orchestrator)"
            echo

            run_gentle "$prompt"
            return $?
        fi

        return 0
    fi

    ########################################
    # SUCCESS: gemini responded normally
    ########################################

    echo "$output"
    return 0
}
