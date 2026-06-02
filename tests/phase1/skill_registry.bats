#!/usr/bin/env bats

load ../test_helper.bash

# Source the module under test
source "$(resolve_core skill_registry)"

setup() {
    setup_test_env
    # Create a temporary skill registry for testing
    export SKILL_REGISTRY_FILE="$TEST_TMPDIR/test-skill-registry.md"
}

teardown() {
    teardown_test_env
}

########################################
# Fixture: Create test skill registry
########################################

create_test_registry() {
    cat > "$SKILL_REGISTRY_FILE" <<'EOF'
# Skill Registry

## rag-research
Skill for RAG and retrieval operations.

## k8s-devops
Skill for Kubernetes and cluster management.

## mern-engineer
Skill for MERN stack development.

## terminal-automation
Skill for terminal and tmux automation.

## editor-engineering
Skill for editor configuration and LSP.
EOF
}

########################################
# load_skill_registry - Success Cases
########################################

@test "load_skill_registry returns 0 when registry exists" {
    # Given
    create_test_registry

    # When
    run load_skill_registry

    # Then
    [[ $status -eq 0 ]]
}

@test "load_skill_registry outputs registry content" {
    # Given
    create_test_registry

    # When
    run load_skill_registry

    # Then
    [[ "$output" == *"## rag-research"* ]]
}

@test "load_skill_registry returns 1 when registry missing" {
    # Given - SKILL_REGISTRY_FILE points to non-existent

    # When
    run load_skill_registry

    # Then
    [[ $status -eq 1 ]]
}

@test "load_skill_registry outputs empty when file empty" {
    # Given
    touch "$SKILL_REGISTRY_FILE"

    # When
    run load_skill_registry

    # Then
    [[ -z "$output" ]]
}

########################################
# skill_exists - Success Cases
########################################

@test "skill_exists returns 0 for known skill" {
    # Given
    create_test_registry

    # When
    run skill_exists "rag-research"

    # Then
    [[ $status -eq 0 ]]
}

@test "skill_exists returns 0 for known skill (case insensitive)" {
    # Given
    create_test_registry

    # When
    run skill_exists "RAG-RESEARCH"

    # Then
    [[ $status -eq 0 ]]
}

@test "skill_exists returns 1 for unknown skill" {
    # Given
    create_test_registry

    # When
    run skill_exists "unknown-skill"

    # Then
    [[ $status -eq 1 ]]
}

@test "skill_exists returns 1 for empty skill name" {
    # Given
    create_test_registry

    # When
    run skill_exists ""

    # Then
    [[ $status -eq 1 ]]
}

@test "skill_exists matches skill by keyword in content" {
    # Given
    create_test_registry

    # When - skill_exists matches on content, not just header
    run skill_exists "kubernetes"

    # Then - should find k8s-devops since "kubernetes" appears in content
    [[ $status -eq 0 ]]
}

########################################
# skill_exists - Missing Registry File
########################################

@test "skill_exists returns 1 when registry file missing" {
    # Given - SKILL_REGISTRY_FILE points to non-existent file

    # When
    run skill_exists "rag-research"

    # Then
    [[ $status -eq 1 ]]
}

########################################
# list_skills - Success Cases
########################################

@test "list_skills returns 0 when registry exists" {
    # Given
    create_test_registry

    # When
    run list_skills

    # Then
    [[ $status -eq 0 ]]
}

@test "list_skills extracts skill names from headers" {
    # Given
    create_test_registry

    # When
    run list_skills

    # Then
    [[ "$output" =~ rag-research ]]
    [[ "$output" =~ k8s-devops ]]
    [[ "$output" =~ mern-engineer ]]
    [[ "$output" =~ terminal-automation ]]
    [[ "$output" =~ editor-engineering ]]
}

@test "list_skills returns only skill names, not headers" {
    # Given
    create_test_registry

    # When
    run list_skills

    # Then
    [[ ! "$output" =~ "^##" ]]
}

@test "list_skills returns one skill per line" {
    # Given
    create_test_registry

    # When
    run list_skills
    local count
    count="$(echo "$output" | wc -l)"

    # Then
    [[ "$count" -eq 5 ]]
}

########################################
# list_skills - Empty/Missing Cases
########################################

@test "list_skills returns 1 when registry file missing" {
    # Given - SKILL_REGISTRY_FILE points to non-existent file

    # When
    run list_skills

    # Then
    [[ $status -eq 1 ]]
}

@test "list_skills returns empty when registry has no skill headers" {
    # Given
    echo "# Just a comment" > "$SKILL_REGISTRY_FILE"

    # When
    run list_skills

    # Then
    [[ -z "$output" ]]
}

########################################
# Integration: Full Workflow
########################################

@test "load_skill_registry followed by skill_exists works" {
    # Given
    create_test_registry

    # When - load registry first
    run load_skill_registry

    # Then - skill_exists should work on loaded registry
    run skill_exists "rag-research"
    [[ $status -eq 0 ]]
}

@test "list_skills count matches number of known skills" {
    # Given
    create_test_registry

    # When
    run list_skills
    local count
    count="$(echo "$output" | grep -c "^")"

    # Then
    [[ "$count" -eq 5 ]]
}

@test "all skills from registry are listable" {
    # Given
    create_test_registry

    # When
    run list_skills

    # Then - each skill should exist
    while IFS= read -r skill; do
        run skill_exists "$skill"
        [[ $status -eq 0 ]]
    done <<< "$output"
}