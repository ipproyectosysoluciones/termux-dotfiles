#!/usr/bin/env bats
# Verify provider-architecture.md contains required sections

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

@test "doc contains provider system overview" {
    grep -q "provider" "$PROJECT_ROOT/docs/provider-architecture.md"
}

@test "doc contains intent routing explanation" {
    grep -q "provider_selector\|intent\|routing" "$PROJECT_ROOT/docs/provider-architecture.md"
}

@test "doc contains fallback chain" {
    grep -q "gemini\|opencode\|gentle\|fallback" "$PROJECT_ROOT/docs/provider-architecture.md"
}

@test "doc contains adding new provider guide" {
    grep -qi "adding\|new provider\|step" "$PROJECT_ROOT/docs/provider-architecture.md"
}

@test "doc contains provider script interface" {
    grep -q "interface\|contract\|function\|exit code" "$PROJECT_ROOT/docs/provider-architecture.md"
}
