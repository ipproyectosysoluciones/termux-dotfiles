#!/usr/bin/env bats

load ../test_helper.bash

WORKFLOW_FILE="$(resolve_script .github/workflows/package.yml)"

@test ".github/workflows/package.yml exists" {
    [[ -f "$WORKFLOW_FILE" ]]
}

@test "package.yml has correct name" {
    grep -q "^name: Package$" "$WORKFLOW_FILE"
}

@test "package.yml triggers on push tags" {
    grep -q "tags:" "$WORKFLOW_FILE"
    grep -q "'v\*'" "$WORKFLOW_FILE"
}

@test "package.yml has build-package job" {
    grep -q "^  build-package:$" "$WORKFLOW_FILE"
}

@test "package.yml uses ubuntu-latest runner" {
    grep -q "runs-on: ubuntu-latest" "$WORKFLOW_FILE"
}

@test "package.yml has permissions contents read" {
    grep -q "permissions:" "$WORKFLOW_FILE"
    grep -q "contents: read" "$WORKFLOW_FILE"
}

@test "package.yml reads VERSION file" {
    grep -q "VERSION" "$WORKFLOW_FILE"
}

@test "package.yml uses dpkg-deb to build" {
    grep -q "dpkg-deb" "$WORKFLOW_FILE"
}

@test "package.yml uploads to GitHub Release" {
    grep -q "softprops/action-gh-release" "$WORKFLOW_FILE"
}

@test "package.yml uploads .deb file" {
    grep -q "\.deb" "$WORKFLOW_FILE"
}