#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# T3.3 - Test: new-mern.sh scaffolding script
# RED phase: tests must exist and fail before script is created

@test "new-mern.sh exists" {
    [ -f "$PROJECT_ROOT/scripts/ai/new-mern.sh" ]
}

@test "new-mern.sh is executable" {
    [ -x "$PROJECT_ROOT/scripts/ai/new-mern.sh" ]
}

@test "new-mern.sh has valid shebang" {
    head -1 "$PROJECT_ROOT/scripts/ai/new-mern.sh" | grep -q "^#!/"
}

@test "new-mern.sh sources menu.sh pattern (SCRIPT_DIR)" {
    grep -q "SCRIPT_DIR=" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates backend directory structure" {
    grep -q "backend.*src.*controllers\|mkdir.*-p.*backend.*controllers" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates frontend directory structure" {
    grep -q "frontend.*src.*app\|frontend.*src.*components\|mkdir.*-p.*frontend" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh supports full-stack scope" {
    grep -q "full-stack" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh supports frontend-only scope" {
    grep -q "frontend-only" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh supports backend-only scope" {
    grep -q "backend-only" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh supports docker flag" {
    grep -qE "docker|Docker" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh sets up husky" {
    grep -q "husky" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh sets up commitlint" {
    grep -q "commitlint" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh sets up lint-staged" {
    grep -q "lint-staged" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates package.json for backend" {
    grep -q "package\.json" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates tsconfig.json for backend" {
    grep -q "tsconfig\.json" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh uses vite" {
    grep -qi "vite" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh uses vitest" {
    grep -qi "vitest" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh uses playwright" {
    grep -qi "playwright" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates docker-compose.yml when docker requested" {
    grep -q "docker-compose\.yml" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh uses gum for input when available" {
    grep -q "gum input\|gum choose\|gum confirm" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh has bash select fallback" {
    grep -q "read -p\|select " "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh initializes git" {
    grep -q "git init" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates initial conventional commit" {
    grep -q "git commit" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh script has at least 200 lines" {
    [ "$(wc -l < "$PROJECT_ROOT/scripts/ai/new-mern.sh")" -ge 200 ]
}
