# Proposal: STACK-MEAN-MERN

## Intent

Add first-class skill and agent support for MEAN (MongoDB, Express, Angular, Node.js) and MERN (MongoDB, Express, React, Node.js) stack development to the Termux-AI-Astaroth workstation. This enables AI-assisted development of full-stack JavaScript applications on the Android+Termux portable dev environment, with shared skills preventing duplication between the two stacks.

## Scope

### In Scope
- `node-express-api` skill — Express.js patterns, middleware, routing, error handling (shared base)
- `mongoose-schema` skill — MongoDB/Mongoose schema design, validation, hooks (shared base)
- `mean-stack` skill — MEAN scaffolding, project structure, Angular integration
- `mern-stack` skill — MERN scaffolding, project structure, React integration
- `mean-developer` agent — MEAN full-stack development assistant
- `mern-developer` agent — MERN full-stack development assistant

### Out of Scope
- `mean-architecture` and `mern-architecture` skills (deferred to Phase 2)
- `express-api-specialist` and `mongo-db-specialist` agents (deferred)
- NestJS, Sails, or other Node frameworks
- SQL database patterns (PostgreSQL/MySQL)

## Capabilities

### New Capabilities
- `node-express-api`: Express.js API development patterns — middleware, routing, error handling, JWT auth, CRUD patterns
- `mongoose-schema`: MongoDB/Mongoose schema design — validation, hooks, indexes, aggregation pipelines
- `mean-stack`: MEAN full-stack scaffolding — Angular project setup, Express API integration, shared patterns
- `mern-stack`: MERN full-stack scaffolding — React project setup, Express API integration, shared patterns
- `mean-developer`: MEAN stack specialist agent with context on both frontend and backend
- `mern-developer`: MERN stack specialist agent with context on both frontend and backend

### Modified Capabilities
- None — existing skills (`angular`, `react-19`, `database-schema-design`, `typescript`) are referenced, not modified

## Approach

### Phasing (Incremental Delivery)

**Phase 1 — Shared Foundation (Skills)**
1. `node-express-api` — Express patterns independent of frontend choice
2. `mongoose-schema` — MongoDB patterns independent of frontend choice

**Phase 2 — Stack-Specific (Skills)**
3. `mean-stack` — MEAN scaffolding + Angular integration patterns (depends on Phase 1)
4. `mern-stack` — MERN scaffolding + React integration patterns (depends on Phase 1)

**Phase 3 — Agents**
5. `mean-developer` agent — references all Phase 1-2 skills
6. `mern-developer` agent — references all Phase 1-2 skills

### Skill Structure Pattern
Each skill follows `skill-creator` pattern with frontmatter:
```yaml
---
name: {skill-name}
description: "Trigger: {trigger words}. {What this skill does}."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---
```
Skills reference existing skills rather than duplicating:
- `mean-stack` and `mern-stack` explicitly reference `scope-rule-architect-angular` and `react-19` respectively
- `mongoose-schema` references `database-schema-design` for generic DB principles, focuses on MongoDB-specific patterns
- All skills reference `typescript` for type patterns

### strict_tdd Compliance
- Each skill creation includes a test-first verification: skill must pass trigger matching tests
- Bats tests in `tests/` subdirectory of each skill folder
- Agent definitions verified against skill registry trigger matching

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `.atl/skill-registry.md` | Modified | Index new skills after creation |
| `~/.config/opencode/skills/node-express-api/SKILL.md` | New | Express.js patterns skill |
| `~/.config/opencode/skills/mongoose-schema/SKILL.md` | New | MongoDB/Mongoose patterns skill |
| `~/.config/opencode/skills/mean-stack/SKILL.md` | New | MEAN stack skill |
| `~/.config/opencode/skills/mern-stack/SKILL.md` | New | MERN stack skill |
| `.claude/agents/mean-developer.md` | New | MEAN specialist agent |
| `.claude/agents/mern-developer.md` | New | MERN specialist agent |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Skill overlap with `angular`, `react-19`, `database-schema-design` | Medium | Explicit cross-references; no duplication of patterns |
| Overlap with `typescript` skill | Low | TypeScript patterns delegated to existing skill |
| strict_tdd test complexity for skill triggers | Medium | Keep trigger tests minimal; verify manually first |
| MEAN/MERN agent context explosion | Low | Agents scope to Phase 1-2 skills only |

## Rollback Plan

1. Remove skill directories from `~/.config/opencode/skills/`
2. Remove agent files from `.claude/agents/`
3. Regenerate `.atl/skill-registry.md` (run `gentle-ai skill-registry refresh --force`)
4. No database migrations or runtime state affected — pure skill/agent addition

## Dependencies

- `skill-creator` skill for SKILL.md generation methodology
- `scope-rule-architect-angular` for Angular 20+ patterns (referenced)
- `react-19` for React patterns (referenced)
- `database-schema-design` for DB principles (referenced)
- `typescript` for TypeScript patterns (referenced)

## Success Criteria

- [ ] `node-express-api` skill created and indexed in registry
- [ ] `mongoose-schema` skill created and indexed in registry
- [ ] `mean-stack` skill created and indexed in registry
- [ ] `mern-stack` skill created and indexed in registry
- [ ] Both new skills trigger correctly when MEAN/MERN keywords used
- [ ] `mean-developer` agent created with proper skill references
- [ ] `mern-developer` agent created with proper skill references
- [ ] No pattern duplication with existing `angular`, `react-19`, `database-schema-design`, `typescript` skills
- [ ] All skills follow `skill-creator` frontmatter pattern
- [ ] Bats tests exist for each skill (strict_tdd compliance)
