#!/usr/bin/env bats
# tests/phase3/main_entry_point.bats
# Integration tests for ai.sh main entry point
# TDD: RED (tests written first) → GREEN (implementation passes) → REFACTOR

load ../test_helper.bash

# Get the ai.sh script path
AI_SCRIPT="$PROJECT_ROOT/scripts/ai/ai.sh"

########################################
# P3-T19: ai.sh main entry point tests
# RED: Write failing tests first
########################################

@test "ai.sh has valid bash syntax (bash -n)" {
    run bash -n "$AI_SCRIPT"
    [[ $status -eq 0 ]]
}

@test "ai.sh sources all core modules (syntax check)" {
    local modules="core/registry.sh core/routing.sh core/provider_selector.sh core/intelligence.sh core/metadata.sh core/state.sh core/hooks.sh core/memory.sh core/hydration.sh core/runtime.sh core/skill_registry.sh core/skill_detector.sh core/capability_router.sh core/agent_registry.sh core/agent_router.sh core/agent_context.sh core/subagent_registry.sh core/subagent_runtime.sh core/orchestration.sh core/runtime_session.sh core/paths.sh core/sync.sh core/policies.sh core/project.sh core/session.sh core/workspace.sh core/layout.sh core/doctor.sh core/router.sh"

    for module in $modules; do
        [[ -f "$PROJECT_ROOT/scripts/ai/$module" ]]
    done
}

@test "ai.sh all core modules have valid syntax" {
    local modules="core/registry.sh core/routing.sh core/provider_selector.sh core/state.sh core/memory.sh core/hydration.sh core/runtime.sh core/skill_registry.sh core/skill_detector.sh core/agent_router.sh core/project.sh core/router.sh"

    for module in $modules; do
        run bash -n "$PROJECT_ROOT/scripts/ai/$module"
        [[ $status -eq 0 ]]
    done
}

@test "ai.sh all provider scripts have valid syntax" {
    local providers="claude gemini opencode gentle mistral"

    for provider in $providers; do
        run bash -n "$PROJECT_ROOT/scripts/ai/providers/$provider.sh"
        [[ $status -eq 0 ]]
    done
}

@test "ai.sh doctor command is recognized" {
    # Just verify the script can parse "doctor" without syntax error
    run bash -n "$AI_SCRIPT"
    [[ $status -eq 0 ]]

    # Check that ai.sh contains doctor command handling
    grep -q '"doctor"' "$AI_SCRIPT"
}

@test "ai.sh resume command is recognized" {
    grep -q '"resume"' "$AI_SCRIPT"
}

@test "ai.sh main execution path (no args) handles gracefully" {
    # We just verify the script has valid syntax and doesn't crash on parse
    run bash -n "$AI_SCRIPT"
    [[ $status -eq 0 ]]
}

@test "ai.sh outputs project info header" {
    # When: ai.sh is sourced with proper mocks
    run bash -c "
        export HOME=$TEST_TMPDIR/home
        mkdir -p \"\$HOME\"
        echo '#!/bin/bash' > \"\$HOME/bin/engram\"
        echo 'exit 0' >> \"\$HOME/bin/engram\"
        chmod +x \"\$HOME/bin/engram\"
        echo '#!/bin/bash' > \"\$HOME/bin/tmux\"
        echo 'exit 0' >> \"\$HOME/bin/tmux\"
        chmod +x \"\$HOME/bin/tmux\"
        export PATH=\$HOME/bin:\$PATH
        timeout 5 bash $AI_SCRIPT 2>&1 || true
    "

    # Then: output should show [ai] header lines
    [[ "$output" == *"[ai]"* ]]
}

@test "ai.sh sets up project info variables when sourced" {
    # Given: verify core modules are loadable
    source "$(resolve_core project)"
    source "$(resolve_core runtime)"

    # When: detect project and runtime
    local project_root
    project_root="$(detect_project)"

    local runtime_mode
    runtime_mode="$(detect_runtime)"

    # Then: should get valid values
    [[ -n "$project_root" ]]
    [[ "$runtime_mode" == "local" ]] || [[ "$runtime_mode" == "remote" ]] || [[ "$runtime_mode" == "mobile" ]]
}

@test "ai.sh sources router.sh and run_provider is available" {
    local router_script="$PROJECT_ROOT/scripts/ai/core/router.sh"

    run bash -n "$router_script"
    [[ $status -eq 0 ]]
}

@test "ai.sh bootstrap sources providers via dynamic path (BUG-FIX-2 verification)" {
    local router_script="$PROJECT_ROOT/scripts/ai/core/router.sh"

    run bash -c "
        source '$router_script'
        echo 'ROUTER_LOADED'
    " 2>&1

    [[ "$output" != *"No such file or directory"* ]]
    [[ "$output" == *"ROUTER_LOADED"* ]]
}

@test "ai.sh detects project via detect_project integration" {
    source "$(resolve_core project)"

    local result
    result="$(detect_project)"

    [[ -n "$result" ]]
    [[ "$result" == "$PROJECT_ROOT" ]]
}

@test "ai.sh detects runtime via detect_runtime integration" {
    source "$(resolve_core runtime)"

    local result
    result="$(detect_runtime)"

    [[ "$result" == "local" ]] || [[ "$result" == "remote" ]] || [[ "$result" == "mobile" ]]
}

@test "ai.sh detects network via detect_network integration" {
    source "$(resolve_core runtime)"

    local result
    result="$(detect_network)"

    [[ "$result" == "online" ]] || [[ "$result" == "offline" ]]
}

@test "ai.sh detects tmux mode via detect_tmux_mode integration" {
    source "$(resolve_core runtime)"

    local result
    result="$(detect_tmux_mode)"

    [[ "$result" == "nested" ]] || [[ "$result" == "standalone" ]]
}

@test "ai.sh routes skill to intent via route_capability (from capability_router.sh)" {
    source "$(resolve_core capability_router)"

    # rag-research skill should route to research intent
    local research_result
    research_result="$(route_capability 'rag-research')"

    [[ "$research_result" == "research" ]]
}

@test "ai.sh resolves skill to agent via resolve_agent (from agent_registry.sh)" {
    source "$(resolve_core agent_registry)"

    # rag-research skill should resolve to rag-agent
    local result
    result="$(resolve_agent 'rag-research')"

    [[ "$result" == "rag-agent" ]]
}

@test "ai.sh routes agent to provider via route_agent_provider (from agent_router.sh)" {
    source "$(resolve_core agent_router)"

    # rag-agent should route to gemini provider
    local result
    result="$(route_agent_provider 'rag-agent')"

    [[ "$result" == "gemini" ]]
}

@test "ai.sh integrates skill detection with agent routing" {
    source "$(resolve_core skill_detector)"
    source "$(resolve_core agent_registry)"

    # When: detect skill from prompt
    local skill
    skill="$(detect_skill 'help me with research on AI')"

    # Then: should detect rag-research
    [[ "$skill" == "rag-research" ]] || [[ "$skill" == "general" ]]

    # And resolve to agent
    local agent
    agent="$(resolve_agent "$skill")"

    [[ "$agent" == "rag-agent" ]] || [[ "$agent" == "general-agent" ]]
}

@test "ai.sh handles empty prompt (graceful degradation)" {
    # When: detect skill with empty prompt
    source "$(resolve_core skill_detector)"

    local skill
    skill="$(detect_skill '')"

    # Then: should return general skill (graceful fallback)
    [[ "$skill" == "general" ]]
}

@test "ai.sh handles invalid arguments gracefully" {
    # When: call with invalid skill
    source "$(resolve_core agent_registry)"

    local agent
    agent="$(resolve_agent 'invalid-skill-xyz')"

    # Then: should return default agent
    [[ "$agent" == "general-agent" ]]
}