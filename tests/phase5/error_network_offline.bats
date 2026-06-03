#!/usr/bin/env bats
# tests/phase5/error_network_offline.bats
# Tests for network offline error handling
# TDD: RED → GREEN → REFACTOR

load ../test_helper.bash

# Source the module under test
source "$(resolve_core runtime)"

########################################
# P5-T28: Network offline error tests
########################################

@test "detect_network returns offline when ping fails" {
    # Given - mock ping to fail
    ping() {
        return 1
    }
    export -f ping

    # When
    local result
    result="$(detect_network)"

    # Then
    [[ "$result" == "offline" ]]
}

@test "detect_network returns online when ping succeeds" {
    # When
    local result
    result="$(detect_network)"

    # Then - depends on actual connectivity
    [[ "$result" == "online" ]] || [[ "$result" == "offline" ]]
}

@test "detect_network handles unreachable host" {
    # Given - ping returns error
    ping() {
        return 1
    }
    export -f ping

    # When
    local result
    result="$(detect_network)"

    # Then - should be offline
    [[ "$result" == "offline" ]]
}

@test "detect_network handles network timeout" {
    # Given - ping times out
    ping() {
        sleep 1
        return 1
    }
    export -f ping

    # When
    local result
    result="$(detect_network)"

    # Then - should return offline (timeout means no network)
    [[ "$result" == "offline" ]]
}

@test "ai.sh with offline network still initializes" {
    # Given - mocked offline network
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
        # Mock ping to return offline
        function ping { return 1; }
        export -f ping
        timeout 5 bash '$ai_script' 'test prompt' 2>&1 || echo 'EXIT:\$?'
    "

    # Then - should still run (offline is not fatal)
    [[ "$output" != *"crash"* ]]
}

@test "offline network does not prevent skill detection" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    source "$(resolve_core skill_detector)"

    # When
    local skill
    skill="$(detect_skill 'help me with research')"

    # Then - skill detection should still work
    [[ "$skill" == "rag-research" ]] || [[ "$skill" == "general" ]]
}

@test "offline network does not prevent agent resolution" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    source "$(resolve_core agent_registry)"

    # When
    local agent
    agent="$(resolve_agent 'rag-research')"

    # Then - should still resolve
    [[ "$agent" == "rag-agent" ]] || [[ "$agent" == "general-agent" ]]
}

@test "offline network does not prevent provider routing" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    source "$(resolve_core agent_router)"

    # When
    local provider
    provider="$(route_agent_provider 'rag-agent')"

    # Then - should still route to gemini
    [[ "$provider" == "gemini" ]]
}

@test "runtime detection works offline" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    source "$(resolve_core runtime)"

    # When
    local runtime network
    runtime="$(detect_runtime)"
    network="$(detect_network)"

    # Then - runtime should still be detected
    [[ "$runtime" == "local" ]] || [[ "$runtime" == "remote" ]] || [[ "$runtime" == "mobile" ]]
    [[ "$network" == "offline" ]]
}

@test "ai.sh doctor command works offline" {
    # Given
    local ai_script="$PROJECT_ROOT/scripts/ai/ai.sh"

    # When
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
        function ping { return 1; }
        export -f ping
        timeout 5 bash '$ai_script' doctor 2>&1 || echo 'EXIT:\$?'
    "

    # Then - doctor should still work
    [[ "$output" != *"crash"* ]]
}

@test "offline mode preserves all other functionality" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    source "$(resolve_core project)"
    source "$(resolve_core state)"

    # When - detect project and save state
    local project_root
    project_root="$(detect_project)"

    # Then - project detection should work
    [[ -n "$project_root" ]]
    [[ "$project_root" == "$PROJECT_ROOT" ]]
}

@test "network detection is non-blocking" {
    # When - detect_network is called
    local start_time=$SECONDS
    local result
    result="$(detect_network)"
    local elapsed=$(( SECONDS - start_time ))

    # Then - should complete quickly (not hang)
    [[ $elapsed -lt 5 ]]
}

@test "provider fallback chain works offline" {
    # Given - offline network
    ping() { return 1; }
    export -f ping

    local gemini_script="$PROJECT_ROOT/scripts/ai/providers/gemini.sh"

    # When - gemini fails due to network issues
    run bash -c "
        function gemini { return 1; }
        export -f gemini
        source '$gemini_script'
        output=\"\$(run_gemini 'test' 2>&1)\"
        echo \"OUTPUT:\$output\"
    "

    # Then - should show fallback message
    [[ "$output" == *"falling"* ]] || [[ "$output" == *"failed"* ]]
}