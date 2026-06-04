#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# Test: mean-stack skill exists on remote
@test "mean-stack skill file exists" {
    # Tests are run locally from repo, but skill is on remote
    # These tests verify the local repo copy which will be synced
    [ -f "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md" ]
}

@test "mean-stack frontmatter is valid YAML" {
    head -5 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md" | grep -q "^---$"
}

@test "mean-stack frontmatter has name field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md" | grep -q "^name:"
}

@test "mean-stack frontmatter has description field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md" | grep -q "^description:"
}

@test "mean-stack triggers on 'mean stack'" {
    grep -qi "mean" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack references scope-rule-architect-angular" {
    grep -qi "scope-rule-architect-angular" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack references node-express-api" {
    grep -qi "node-express-api" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack references mongoose-schema" {
    grep -qi "mongoose-schema" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has Angular HttpClient section" {
    grep -qi "HttpClient\|httpClient" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has JWT interceptor pattern" {
    grep -qi "intercept\|JWT.*interceptor\|token.*interceptor" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has auth guards section" {
    grep -qi "guard\|CanActivate\|auth.*guard" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has proxy config section" {
    grep -qi "proxy\|proxy\.conf\.json" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has CORS section" {
    grep -qi "CORS\|cors" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack has auth flow section" {
    grep -qi "auth.*flow\|login.*token\|refresh.*token" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md"
}

@test "mean-stack file has at least 150 lines" {
    [ "$(wc -l < "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mean-stack/SKILL.md")" -ge 150 ]
}