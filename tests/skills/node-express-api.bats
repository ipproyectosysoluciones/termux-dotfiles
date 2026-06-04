#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# Test: node-express-api skill exists on remote
@test "node-express-api skill file exists" {
    # Tests are run locally from repo, but skill is on remote
    # These tests verify the local repo copy which will be synced
    [ -f "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md" ]
}

@test "node-express-api frontmatter is valid YAML" {
    head -5 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md" | grep -q "^---$"
}

@test "node-express-api frontmatter has name field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md" | grep -q "^name:"
}

@test "node-express-api frontmatter has description field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md" | grep -q "^description:"
}

@test "node-express-api triggers on 'express api'" {
    grep -qi "express.*api\|api.*express" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api triggers on 'express middleware'" {
    grep -qi "middleware" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api triggers on 'JWT auth'" {
    grep -qi "jwt\|JWT" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api triggers on 'router pattern'" {
    grep -qi "router" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api references typescript skill" {
    grep -qi "typescript" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api references api-design-principles skill" {
    grep -qi "api-design-principles" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has Router pattern section" {
    grep -qi "router.*pattern\|express\.Router" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has middleware section" {
    grep -qi "middleware.*chain\|chain.*middleware" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has REST conventions section" {
    grep -qi "REST\|rest.*convention" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has JWT auth section" {
    grep -qi "JWT\|Bearer\|token" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has async wrapper section" {
    grep -qi "async.*wrapper\|wrapper\|promise" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api has env config section" {
    grep -qi "env.*config\|\.env\|process\.env" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md"
}

@test "node-express-api file has at least 100 lines" {
    [ "$(wc -l < "$PROJECT_ROOT/skills/STACK-MEAN-MERN/node-express-api/SKILL.md")" -ge 100 ]
}