#!/usr/bin/env bats
# tests/phase5/error_empty_prompt.bats
# Tests for empty prompt error handling
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_core skill_detector)"

########################################
# P5-T25: Empty prompt error tests
########################################

@test "detect_skill handles empty string prompt" {
    # When
    local result
    result="$(detect_skill '')"
    # Then - should return general skill (graceful fallback)
    [[ "$result" == "general" ]]
}

@test "detect_skill handles no arguments" {
    # When
    local result
    result="$(detect_skill)"
    # Then - should return general skill
    [[ "$result" == "general" ]]
}

@test "detect_skill handles whitespace-only prompt" {
    # When
    local result
    result="$(detect_skill '   ')"
    # Then - should return general skill (graceful fallback)
    [[ "$result" == "general" ]]
}

@test "detect_skill handles tab-only prompt" {
    # When
    local result
    result="$(detect_skill $'\t')"
    # Then - should return general skill
    [[ "$result" == "general" ]]
}

@test "detect_skill handles newline-only prompt" {
    # When
    local result
    result="$(detect_skill $'\n')"
    # Then - should return general skill
    [[ "$result" == "general" ]]
}

@test "detect_skill handles mixed whitespace prompt" {
    # When
    local result
    result="$(detect_skill $'  \t\n  ')"
    # Then - should return general skill
    [[ "$result" == "general" ]]
}

@test "detect_skill handles null-like input" {
    # When
    local result
    result="$(detect_skill '')"
    # Then - should not crash, should return default
    [[ "$result" == "general" ]]
}

@test "detect_skill valid prompt still works after empty ones" {
    # Given - a valid prompt with skill indicator
    local prompt="帮我用rag-research研究这个"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then - should detect the skill
    [[ "$result" == "rag-research" ]]
}

@test "ai.sh with no arguments handles gracefully" {
    # Given - an ai.sh script with no PROMPT
    local ai_script="$PROJECT_ROOT/scripts/ai/ai.sh"

    # When - source ai.sh with empty args (simulating no prompt)
    run bash -c "
        export HOME='$TEST_TMPDIR/home'
        mkdir -p '$HOME/.ai'
        echo '#!/bin/bash' > '$HOME/bin/engram'
        echo 'exit 0' >> '$HOME/bin/engram'
        chmod +x '$HOME/bin/engram'
        echo '#!/bin/bash' > '$HOME/bin/tmux'
        echo 'exit 0' >> '$HOME/bin/tmux'
        chmod +x '$HOME/bin/tmux'
        export PATH='$HOME/bin:$PATH'
        timeout 3 bash '$ai_script' 2>&1 || true
    "

    # Then - should not crash, should show usage or default behavior
    [[ "$output" == *"[ai]"* ]] || [[ -z "$output" ]]
}

@test "ai.sh empty prompt results in general skill" {
    # Given
    source "$(resolve_core skill_detector)"

    # When
    local skill
    PROMPT="" skill="$(detect_skill '')"

    # Then
    [[ "$skill" == "general" ]]
}

@test "ai.sh empty prompt results in general-agent" {
    # Given
    source "$(resolve_core agent_registry)"

    # When
    local agent
    agent="$(resolve_agent 'general')"

    # Then - general skill maps to general-agent
    [[ "$agent" == "general-agent" ]]
}

@test "ai.sh handles prompt that is only spaces via skill detection" {
    # When
    local result
    result="$(detect_skill '   ')"
    # Then - should return general not empty
    [[ "$result" != "" ]]
    [[ "$result" == "general" ]]
}

@test "resolve_agent with empty skill returns default" {
    # Given
    source "$(resolve_core agent_registry)"

    # When
    local agent
    agent="$(resolve_agent '')"

    # Then - should return default agent
    [[ "$agent" == "general-agent" ]]
}

@test "route_capability with empty input returns default intent" {
    # Given
    source "$(resolve_core capability_router)"

    # When
    local intent
    intent="$(route_capability '')"

    # Then - should return default intent (lightweight from capability_router)
    [[ "$intent" == "lightweight" ]]
}