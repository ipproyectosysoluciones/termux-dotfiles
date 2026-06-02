#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core agent_router)"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "route_agent_provider routes rag-agent to gemini" {
    # Given
    local agent="rag-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "gemini" ]]
}

@test "route_agent_provider routes kubernetes-agent to opencode" {
    # Given
    local agent="kubernetes-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider routes mern-agent to claude" {
    # Given
    local agent="mern-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "claude" ]]
}

@test "route_agent_provider routes terminal-agent to opencode" {
    # Given
    local agent="terminal-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider routes editor-agent to claude" {
    # Given
    local agent="editor-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "claude" ]]
}

@test "route_agent_provider routes mistral to mistral" {
    # Given
    local agent="mistral"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "mistral" ]]
}

@test "route_agent_provider defaults to opencode for unknown agent" {
    # Given
    local agent="unknown-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider defaults to opencode when agent is empty" {
    # Given
    local agent=""

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider handles general-agent as default" {
    # Given
    local agent="general-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider handles arbitrary agent name" {
    # Given
    local agent="some-random-agent-name"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider is case-sensitive for agent names" {
    # Given
    local agent="RAG-agent"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "route_agent_provider handles agent with numbers" {
    # Given
    local agent="agent123"

    # When
    local result
    result="$(route_agent_provider "$agent")"

    # Then
    [[ "$result" == "opencode" ]]
}