#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# T3.6 - Test: scaffold directory structure validation
# Verifies the generated project structure patterns in scaffolding scripts

@test "new-mean.sh creates backend/src structure" {
    grep -qE "mkdir.*-p.*backend/src/(controllers|models|routes|middleware|config)" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates frontend/src structure" {
    grep -qE "mkdir.*-p.*frontend/src/(app|components|services|guards|interceptors)" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates tests/unit and tests/integration directories" {
    grep -qE "mkdir.*-p.*(backend|frontend)/tests/(unit|integration|e2e)" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates .husky directory with hooks" {
    grep -qE "\.husky/(pre-commit|commit-msg|pre-push)" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates .env.example" {
    grep -q "\.env\.example" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates jest.config.ts" {
    grep -q "jest\.config\.ts" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mean.sh creates Dockerfile when docker requested" {
    grep -qE "Dockerfile" "$PROJECT_ROOT/scripts/ai/new-mean.sh"
}

@test "new-mern.sh creates backend/src structure" {
    grep -qE "mkdir.*-p.*backend/src/(controllers|models|routes|middleware|config)" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates frontend/src structure" {
    grep -qE "mkdir.*-p.*frontend/src/(app|components|services)" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates tests/unit and tests/e2e directories" {
    grep -qE "mkdir.*-p.*(backend|frontend)/tests/(unit|integration|e2e)" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "new-mern.sh creates proxy.conf.json for Vite" {
    grep -q "proxy\.conf\.json" "$PROJECT_ROOT/scripts/ai/new-mern.sh"
}

@test "menu.sh has New Project entry" {
    grep -q "New Project" "$PROJECT_ROOT/scripts/ai/menu.sh"
}

@test "new-project.sh has MEAN Full Stack option" {
    grep -q "MEAN Full Stack" "$PROJECT_ROOT/scripts/ai/new-project.sh"
}

@test "new-project.sh has MERN Full Stack option" {
    grep -q "MERN Full Stack" "$PROJECT_ROOT/scripts/ai/new-project.sh"
}

@test "new-project.sh has frontend-only options" {
    grep -q "Frontend Only" "$PROJECT_ROOT/scripts/ai/new-project.sh"
}

@test "new-project.sh has backend-only options" {
    grep -q "Backend Only" "$PROJECT_ROOT/scripts/ai/new-project.sh"
}
