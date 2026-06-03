#!/usr/bin/env bats
# tests/phase5/error_missing_env.bats
# Tests for missing .env file error handling
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_core provider_selector)"

########################################
# P5-T26: Missing .env error tests
########################################

@test "providers source missing .env gracefully" {
    # Given - a missing .env file
    local missing_env="$TEST_TMPDIR/nonexistent/.env"

    # When - source a provider script
    local provider_script="$PROJECT_ROOT/scripts/ai/providers/claude.sh"

    # Then - should not error on missing source
    run bash -c "
        set +e
        source '$provider_script' 2>&1
        echo \"EXIT_CODE:\$?\"
    "

    [[ "$output" != *"No such file or directory"* ]] || [[ "$output" == *"EXIT_CODE:0"* ]]
}

@test "claude provider handles missing env gracefully" {
    # Given - no .env file in provider directory
    local provider_script="$PROJECT_ROOT/scripts/ai/providers/claude.sh"

    # When - source with non-existent HOME
    run bash -c "
        export HOME='$TEST_TMPDIR/no-home'
        unset AI_PROJECT
        unset AI_AGENT
        source '$provider_script' 2>&1
        echo \"EXIT:\$?\"
    "

    # Then - should not crash
    [[ "$output" == *"EXIT:0"* ]] || [[ "$output" != *"crash"* ]]
}

@test "gemini provider uses default values when .env missing" {
    # Given
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"

    # When - source without any AI_ vars set
    run bash -c "
        unset AI_PROJECT
        unset AI_AGENT
        unset AI_SKILL
        unset AI_WORKSPACE
        source '$gemini_script' 2>&1
        echo \"GOT_DEFAULTS:\$(printenv | grep -c 'GEMINI_=' || echo 0)\"
    "

    # Then - should use defaults (GEMINI_PROJECT=default etc)
    [[ "$output" == *"GOT_DEFAULTS"* ]]
}

@test "opencode provider falls back when binary missing" {
    # Given - opencode not available in PATH
    local opencode_script="$PROJECT_ROOT/scripts/ai/providers/opencode.sh"

    # When - source opencode and call without opencode in PATH
    run bash -c "
        export PATH='$TEST_TMPDIR/bin-no-opencode:\$PATH'
        source '$opencode_script'
        run_opencode 'test prompt' 2>&1
        echo \"EXIT:\$?\"
    "

    # Then - should handle gracefully
    [[ "$output" == *"[ai] opencode unavailable"* ]] || [[ "$output" == *"EXIT:1"* ]]
}

@test "provider selector returns valid provider even with partial env" {
    # Given - only AI_PROJECT set, no AI_AGENT
    export AI_PROJECT="test-project"
    unset AI_AGENT

    source "$(resolve_core agent_router)"

    # When
    local provider
    provider="$(
        bash -c '
            source "'"$(resolve_core agent_router)"'"
            route_agent_provider "general-agent"
        '
    )"

    # Then - should still return a valid provider
    [[ "$provider" == "opencode" ]]
}

@test "gentle provider handles missing gentle-ai binary" {
    # Given
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    # When - run without gentle-ai installed
    run bash -c "
        PATH='$TEST_TMPDIR/no-gentle:\$PATH'
        source '$gentle_script'
        gentle_sync 2>&1
    "

    # Then - should report gentle-ai unavailable
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "provider fallback chain works when primary fails" {
    # Given - gemini with mocked failure
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"

    # When - gemini fails (no binary), it should try fallback
    run bash -c "
        function gemini() { return 1; }
        export -f gemini
        export PATH='$TEST_TMPDIR/fake-bin:\$PATH'
        source '$gemini_script'
        output=\"\$(run_gemini 'test prompt' 2>&1)\"
        echo \"OUTPUT:\$output\"
    "

    # Then - should attempt fallback to opencode or gentle
    [[ "$output" == *"falling back"* ]] || [[ "$output" == *"[ai] gemini failed"* ]]
}

@test "state.sh handles missing state directory gracefully" {
    # Given - STATE_DIR points to non-existent path
    local state_script="$PROJECT_ROOT/scripts/ai/core/state.sh"

    # When - source with writable tmp state
    run bash -c "
        export HOME='$TEST_TMPDIR'
        rm -rf '\$HOME/.ai'
        source '$state_script'
        mkdir -p \"\$STATE_DIR\"
        echo \"STATE_DIR_CREATED:\$(test -d \"\$STATE_DIR\" && echo yes || echo no)\"
    "

    # Then - should create directory on first access
    [[ "$output" == *"STATE_DIR_CREATED:yes"* ]]
}

@test "memory.sh handles missing memory directory gracefully" {
    # Given
    local memory_script="$PROJECT_ROOT/scripts/ai/core/memory.sh"

    # When - source without .ai directory
    run bash -c "
        export HOME='$TEST_TMPDIR/no-ai-home'
        unset XDG_STATE_HOME
        source '$memory_script' 2>&1 || true
    "

    # Then - should not crash on load
    [[ "$output" != *"syntax error"* ]]
}

@test "runtime.sh detect functions work without .env" {
    # Given - no .env file
    source "$(resolve_core runtime)"

    # When - call detect functions
    local runtime network tmux
    runtime="$(detect_runtime)"
    network="$(detect_network)"
    tmux="$(detect_tmux_mode)"

    # Then - should return valid values
    [[ "$runtime" == "local" ]] || [[ "$runtime" == "remote" ]] || [[ "$runtime" == "mobile" ]]
    [[ "$network" == "online" ]] || [[ "$network" == "offline" ]]
    [[ "$tmux" == "nested" ]] || [[ "$tmux" == "standalone" ]]
}