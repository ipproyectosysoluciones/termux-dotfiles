#!/usr/bin/env bats

# Load test helper for PROJECT_ROOT resolution
load ../test_helper.bash

# Test: mongoose-schema skill exists on remote
@test "mongoose-schema skill file exists" {
    [ -f "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md" ]
}

@test "mongoose-schema frontmatter is valid YAML" {
    head -5 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md" | grep -q "^---$"
}

@test "mongoose-schema frontmatter has name field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md" | grep -q "^name:"
}

@test "mongoose-schema frontmatter has description field" {
    head -10 "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md" | grep -q "^description:"
}

@test "mongoose-schema triggers on 'mongoose schema'" {
    grep -qi "mongoose" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema triggers on 'mongodb model'" {
    grep -qi "mongodb" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema triggers on 'schema validation'" {
    grep -qi "validation\|Schema\.Types" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema triggers on 'indexes'" {
    grep -qi "index\|unique\|compound" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema triggers on 'hooks'" {
    grep -qi "pre\|post\|hook\|middleware" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema references database-schema-design skill" {
    grep -qi "database-schema-design" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has schema definition section" {
    grep -qi "new Schema\|Schema\..Types\|defineSchema" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has validation section" {
    grep -qi "required\|min\|max\|enum\|match" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has indexes section" {
    grep -qi "index.*true\|unique.*true\|compound.*index" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has hooks section" {
    grep -qiE "^pre|^post|\\.pre\\(|\\.post\\(" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has query patterns section" {
    grep -qi "findById\|findOne\|\.populate\|\.select" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema has soft delete section" {
    grep -qi "soft.*delete\|deletedAt\|isDeleted\|paranoid" "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md"
}

@test "mongoose-schema file has at least 80 lines" {
    [ "$(wc -l < "$PROJECT_ROOT/skills/STACK-MEAN-MERN/mongoose-schema/SKILL.md")" -ge 80 ]
}