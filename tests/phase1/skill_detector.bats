#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core skill_detector)"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

########################################
# detect_skill - RAG Detection
########################################

@test "detect_skill matches rag keyword (lowercase)" {
    # Given
    local prompt="help me with rag research"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

@test "detect_skill matches rag keyword (uppercase)" {
    # Given
    local prompt="HELP ME WITH RAG RESEARCH"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

@test "detect_skill matches retrieval keyword" {
    # Given
    local prompt="help with retrieval augmented generation"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

@test "detect_skill matches embedding keyword" {
    # Given
    local prompt="embedding model setup"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

@test "detect_skill matches vector keyword" {
    # Given
    local prompt="vector database configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

########################################
# detect_skill - Kubernetes Detection
########################################

@test "detect_skill matches kubernetes keyword" {
    # Given
    local prompt="kubernetes deployment configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "k8s-devops" ]]
}

@test "detect_skill matches k8s keyword" {
    # Given
    local prompt="k8s cluster setup"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "k8s-devops" ]]
}

@test "detect_skill matches helm keyword" {
    # Given
    local prompt="helm chart creation"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "k8s-devops" ]]
}

@test "detect_skill matches cluster keyword" {
    # Given
    local prompt="cluster management"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "k8s-devops" ]]
}

########################################
# detect_skill - MERN Detection
########################################

@test "detect_skill matches react keyword" {
    # Given
    local prompt="react component development"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "mern-engineer" ]]
}

@test "detect_skill matches node keyword" {
    # Given
    local prompt="node js backend"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "mern-engineer" ]]
}

@test "detect_skill matches mern keyword" {
    # Given
    local prompt="mern stack application"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "mern-engineer" ]]
}

########################################
# detect_skill - Terminal Automation Detection
########################################

@test "detect_skill matches terminal keyword" {
    # Given
    local prompt="terminal session management"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "terminal-automation" ]]
}

@test "detect_skill matches tmux keyword" {
    # Given
    local prompt="tmux configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "terminal-automation" ]]
}

@test "detect_skill matches session keyword" {
    # Given
    local prompt="session management in terminal"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "terminal-automation" ]]
}

########################################
# detect_skill - Editor Engineering Detection
########################################

@test "detect_skill matches nvim keyword" {
    # Given
    local prompt="neovim configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "editor-engineering" ]]
}

@test "detect_skill matches editor keyword" {
    # Given
    local prompt="editor configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "editor-engineering" ]]
}

@test "detect_skill matches lsp keyword" {
    # Given
    local prompt="lsp configuration"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "editor-engineering" ]]
}

########################################
# detect_skill - General Fallback
########################################

@test "detect_skill defaults to general for unknown prompts" {
    # Given
    local prompt="random unrelated prompt"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "general" ]]
}

@test "detect_skill handles empty prompt" {
    # Given
    local prompt=""

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "general" ]]
}

########################################
# detect_skill - Case Insensitivity
########################################

@test "detect_skill is case insensitive for RAG" {
    # Given - mixed case prompt with rag
    local prompt="Rag Research Please"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "rag-research" ]]
}

@test "detect_skill is case insensitive for Kubernetes" {
    # Given - uppercase kubernetes
    local prompt="KUBERNETES DEPLOYMENT"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "k8s-devops" ]]
}

@test "detect_skill is case insensitive for React" {
    # Given - uppercase react
    local prompt="REACT COMPONENT"

    # When
    local result
    result="$(detect_skill "$prompt")"

    # Then
    [[ "$result" == "mern-engineer" ]]
}