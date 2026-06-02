#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core provider_selector)"

# Mock provider_available function
provider_available() {
    local provider="$1"
    case "$provider" in
        gemini)
            [[ "$FAKE_GEMINI_AVAILABLE" == "true" ]]
            ;;
        opencode)
            [[ "$FAKE_OPENCODE_AVAILABLE" != "false" ]]
            ;;
        mistral)
            [[ "$FAKE_MISTRAL_AVAILABLE" == "true" ]]
            ;;
        claude)
            [[ "$FAKE_CLAUDE_AVAILABLE" == "true" ]]
            ;;
        gentle)
            [[ "$FAKE_GENTLE_AVAILABLE" == "true" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

setup() {
    setup_test_env
    export FAKE_GEMINI_AVAILABLE="true"
    export FAKE_OPENCODE_AVAILABLE="true"
    export FAKE_MISTRAL_AVAILABLE="true"
    export FAKE_CLAUDE_AVAILABLE="true"
    export FAKE_GENTLE_AVAILABLE="true"
}

teardown() {
    teardown_test_env
}

@test "select_provider routes research intent to gemini" {
    # Given
    local intent="research"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "gemini" ]]
}

@test "select_provider routes architecture intent to gemini" {
    # Given
    local intent="architecture"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "gemini" ]]
}

@test "select_provider routes devops intent to opencode" {
    # Given
    local intent="devops"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider routes coding intent to opencode" {
    # Given
    local intent="coding"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider routes mistral intent to mistral" {
    # Given
    local intent="mistral"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "mistral" ]]
}

@test "select_provider falls back to opencode when mistral unavailable" {
    # Given
    local intent="mistral"
    export FAKE_MISTRAL_AVAILABLE="false"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider defaults to opencode for unknown intent" {
    # Given
    local intent="unknown-intent"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider defaults to opencode when intent is empty" {
    # Given
    local intent=""

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider falls back to opencode when gemini unavailable for research" {
    # Given
    local intent="research"
    export FAKE_GEMINI_AVAILABLE="false"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider falls back to opencode when gemini unavailable for architecture" {
    # Given
    local intent="architecture"
    export FAKE_GEMINI_AVAILABLE="false"

    # When
    local result
    result="$(select_provider "generic" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "opencode" ]]
}

@test "select_provider ignores project_type parameter" {
    # Given
    local intent="research"

    # When
    local result
    result="$(select_provider "node" "mobile" "lightweight" "$intent")"

    # Then
    [[ "$result" == "gemini" ]]
}

@test "select_provider ignores runtime parameter" {
    # Given
    local intent="research"

    # When
    local result
    result="$(select_provider "generic" "remote" "lightweight" "$intent")"

    # Then
    [[ "$result" == "gemini" ]]
}

@test "select_provider ignores policy parameter" {
    # Given
    local intent="research"

    # When
    local result
    result="$(select_provider "generic" "mobile" "heavy" "$intent")"

    # Then
    [[ "$result" == "gemini" ]]
}