#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# Test: mern-stack skill exists on remote
@test "mern-stack skill file exists" {
    # Tests are run locally from repo, but skill is on remote
    # These tests verify the local repo copy which will be synced
    [ -f "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md" ]
}

@test "mern-stack frontmatter is valid YAML" {
    head -5 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md" | grep -q "^---$"
}

@test "mern-stack frontmatter has name field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md" | grep -q "^name:"
}

@test "mern-stack frontmatter has description field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md" | grep -q "^description:"
}

@test "mern-stack triggers on 'mern stack'" {
    grep -qi "mern" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack references react-19" {
    grep -qi "react-19" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack references node-express-api" {
    grep -qi "node-express-api" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack references mongoose-schema" {
    grep -qi "mongoose-schema" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack references vite" {
    grep -qi "vite" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack has React auth context section" {
    grep -qi "createContext\|useContext\|auth.*context\|AuthContext" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack has fetch/axios pattern" {
    grep -qi "axios\|fetch.*auth\|auth.*header" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack has protected routes section" {
    grep -qi "protected.*route\|route.*protection\|Navigate\|PrivateRoute" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack has Vite proxy config" {
    grep -qi "vite.*proxy\|proxy.*config" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack has auth flow section" {
    grep -qi "auth.*flow\|login.*token\|refresh.*token" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md"
}

@test "mern-stack file has at least 150 lines" {
    [ "$(wc -l < "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mern-stack/SKILL.md")" -ge 150 ]
}