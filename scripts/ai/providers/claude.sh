#!/data/data/com.termux/files/usr/bin/bash

export CLAUDE_PROJECT="${AI_PROJECT:-default}"
export CLAUDE_AGENT="${AI_AGENT:-generic-agent}"
export CLAUDE_SKILL="${AI_SKILL:-generic-skill}"
export CLAUDE_WORKSPACE="${AI_WORKSPACE:-$PWD}"

cd "$CLAUDE_WORKSPACE" || exit 1

run_claude() {

    local prompt="$*"

    claude "$prompt"
}
