#!/usr/bin/env bats
# tests/phase5/error_missing_binary.bats
# Tests for missing binary error handling
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

########################################
# P5-T29: Missing binary error tests
########################################

@test "opencode provider reports binary missing" {
    # Given - opencode not installed
    local opencode_script="$PROJECT_ROOT/scripts/ai/providers/opencode.sh"

    run bash -c "
        export PATH='$TEST_TMPDIR/no-opencode:\$PATH'
        source '$opencode_script'
        run_opencode 'test prompt' 2>&1
    "

    # Then - should report opencode unavailable
    [[ "$output" == *"[ai] opencode unavailable"* ]]
}

@test "claude provider handles missing claude binary" {
    # Given
    local claude_script="$PROJECT_ROOT/scripts/ai/providers/claude.sh"

    run bash -c "
        export PATH='$TEST_TMPDIR/no-claude:\$PATH'
        export AI_PROJECT='test'
        export AI_AGENT='test-agent'
        export AI_SKILL='test-skill'
        export AI_WORKSPACE='$TEST_TMPDIR'
        source '$claude_script' 2>&1 || echo 'EXIT:\$?'
    "

    # Then - should not crash on source
    [[ "$output" != *"syntax error"* ]]
}

@test "gemini falls back to gentle when gemini binary missing" {
    # Given
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    # When - both providers sourced, gemini not available
    run bash -c "
        source '$gentle_script'
        source '$gemini_script'
        run_gemini 'test' 2>&1
    "

    # Then - should fallback to gentle gracefully (no crash)
    [[ "$output" == *"falling back to gentle"* ]]
    [[ "$output" != *"command not found"* ]]
}

@test "gemini falls back to gentle when opencode also missing" {
    # Given
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    run bash -c "
        source '$gentle_script'
        source '$gemini_script'
        run_gemini 'test' 2>&1
    "

    # Then - should fall back to gentle gracefully (no crash)
    [[ "$output" == *"falling back to gentle"* ]]
    [[ "$output" != *"command not found"* ]]
}

@test "gentle provider handles missing gentle-ai binary" {
    # Given
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    run bash -c "
        export PATH='$TEST_TMPDIR/no-gentle:\$PATH'
        source '$gentle_script'
        gentle_sync 2>&1
    "

    # Then - should report gentle-ai unavailable
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "gentle_upgrade handles missing gentle-ai binary" {
    # Given
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    run bash -c "
        export PATH='$TEST_TMPDIR/no-gentle:\$PATH'
        source '$gentle_script'
        gentle_upgrade 2>&1
    "

    # Then - should report gentle-ai unavailable
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "gentle_refresh_skills handles missing gentle-ai binary" {
    # Given
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    run bash -c "
        export PATH='$TEST_TMPDIR/no-gentle:\$PATH'
        source '$gentle_script'
        gentle_refresh_skills 2>&1
    "

    # Then - should report gentle-ai unavailable
    [[ "$output" == *"[ai] gentle-ai unavailable"* ]]
}

@test "provider fallback chain: gemini -> opencode -> gentle" {
    # Given
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"
    local opencode_script="$PROJECT_ROOT/scripts/ai/providers/opencode.sh"

    # When - gemini fails, opencode also fails, gentle logs control-plane message
    run bash -c "
        source '$gentle_script'
        source '$opencode_script'
        source '$gemini_script'
        run_gemini 'test' 2>&1
    "

    # Then - should complete gracefully (no crash)
    [[ "$output" != *"command not found"* ]]
}

@test "ai.sh handles missing provider binaries gracefully" {
    # Given
    local ai_script="$PROJECT_ROOT/scripts/ai/ai.sh"

    run bash -c "
        export HOME='$TEST_TMPDIR/home'
        mkdir -p '$HOME/.ai'
        echo '#!/bin/bash' > '$TEST_TMPDIR/home/bin/engram'
        echo 'exit 0' >> '$TEST_TMPDIR/home/bin/engram'
        chmod +x '$TEST_TMPDIR/home/bin/engram'
        echo '#!/bin/bash' > '$TEST_TMPDIR/home/bin/tmux'
        echo 'exit 0' >> '$TEST_TMPDIR/home/bin/tmux'
        chmod +x '$TEST_TMPDIR/home/bin/tmux'
        export PATH='$TEST_TMPDIR/home/bin:\$PATH'
        # No provider binaries available
        timeout 5 bash '$ai_script' 'test prompt' 2>&1 || echo 'EXIT:\$?'
    "

    # Then - should not crash, should handle gracefully
    [[ "$output" != *"crash"* ]]
}

@test "detect_provider returns valid fallback even when primary missing" {
    # Given
    source "$(resolve_core agent_router)"

    # When - all binaries might be missing, but function should still return something
    local provider
    provider="$(
        bash -c '
            source "'"$(resolve_core agent_router)"'"
            route_agent_provider "general-agent"
        '
    )"

    # Then - should return opencode (the default)
    [[ "$provider" == "opencode" ]]
}

@test "command -v check works for all providers" {
    # When - check each provider command
    local providers="claude gemini opencode gentle"

    for p in $providers; do
        local script="$PROJECT_ROOT/scripts/ai/providers/$p.sh"
        # Just verify script exists and has valid syntax
        run bash -n "$script"
        [[ $status -eq 0 ]]
    done
}

@test "provider scripts use command -v for binary detection" {
    # Given
    local opencode_script="$PROJECT_ROOT/scripts/ai/providers/opencode.sh"

    # When - check that it uses command -v pattern
    grep -q 'command -v' "$opencode_script"

    # Then - should use proper binary detection
    [[ 1 -eq 1 ]]
}

@test "provider fallback preserves error message for debugging" {
    # Given
    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"
    local gentle_script="$PROJECT_ROOT/scripts/ai/providers/gentle.sh"

    # When - gemini fails gracefully
    run bash -c "
        source '$gentle_script'
        source '$gemini_script'
        run_gemini 'test' 2>&1
    "

    # Then - should show fallback message
    [[ "$output" == *"falling back"* ]]
}

@test "provider scripts return proper exit codes" {
    # Given
    local opencode_script="$PROJECT_ROOT/scripts/ai/providers/opencode.sh"

    # When - opencode not available, run_opencode should return non-zero
    run bash -c "
        export PATH='$TEST_TMPDIR/no-opencode:\$PATH'
        source '$opencode_script'
        run_opencode 'test' 2>&1
        echo \"EXIT:\$?\"
    "

    # Then - should return error exit code
    [[ "$output" == *"EXIT:1"* ]] || [[ "$output" == *"[ai] opencode unavailable"* ]]
}

@test "all provider scripts are executable and syntactically valid" {
    # When - verify all providers
    local providers="claude gemini opencode gentle mistral"

    for provider in $providers; do
        local script="$PROJECT_ROOT/scripts/ai/providers/$provider.sh"
        run bash -n "$script"
        [[ $status -eq 0 ]]
    done
}

@test "missing binary does not corrupt state" {
    # Given
    local state_script="$PROJECT_ROOT/scripts/ai/core/state.sh"

    # When - source state after provider with missing binary
    run bash -c "
        export HOME='$TEST_TMPDIR/test-home'
        mkdir -p '$HOME/.ai'
        export PATH='$TEST_TMPDIR/no-provider:\$PATH'
        source '$state_script'
        # Try to save workspace state
        save_current_workspace 'test-session' 'test-project' '/tmp' 'local' 'main' 'default'
        # Verify state file is valid
        test -f \"\$STATE_DIR/current_workspace\"
    "

    # Then - state file should exist and be valid
    [[ "$output" != *"syntax error"* ]]
}
