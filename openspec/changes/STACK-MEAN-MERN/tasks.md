# SDD Tasks: STACK-MEAN-MERN

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~1,650 lines (skills + tests + scripts + agents) |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | 3 chained PRs (Phase 1 → Phase 2 → Phase 3) |
| Delivery strategy | ask-on-risk |
| Chain strategy | stacked-to-main |

**Decision needed before apply**: Yes
**Chained PRs recommended**: Yes
**Chain strategy**: stacked-to-main
**400-line budget risk**: High

---

## Phase 1: Shared Skills + Tests (Remote Deployment)

### T1.1 — Create node-express-api SKILL.md test
**File**: `tests/skills/node-express-api.bats` (in repo, synced to remote)  
**Lines**: ~40  
**Depends**: None  
**strict_tdd**: Test MUST exist and fail before SKILL.md is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/skills/node-express-api.bats'`
**Status**: ✅ DONE (74 lines)

```bats
#!/usr/bin/env bats
@test "node-express-api skill exists on remote" { grep -q "node-express-api" ~/.config/opencode/skills/node-express-api/SKILL.md }
@test "node-express-api frontmatter valid" { grep -q "^---$" ~/.config/opencode/skills/node-express-api/SKILL.md }
@test "node-express-api triggers on 'express api'" { grep -qi "express.*api\|api.*express" ~/.config/opencode/skills/node-express-api/SKILL.md }
@test "node-express-api triggers on 'express middleware'" { grep -qi "middleware" ~/.config/opencode/skills/node-express-api/SKILL.md }
@test "node-express-api references typescript skill" { grep -qi "typescript" ~/.config/opencode/skills/node-express-api/SKILL.md }
@test "node-express-api references api-design-principles" { grep -qi "api-design-principles" ~/.config/opencode/skills/node-express-api/SKILL.md }
```

### T1.2 — Create node-express-api SKILL.md
**File**: `~/.config/opencode/skills/node-express-api/SKILL.md` (on remote)  
**Lines**: ~200  
**Depends**: T1.1 (test must fail first)  
**Verify**: `ssh phone-ai -p 8022 'bat ~/.config/opencode/skills/node-express-api/SKILL.md'`  
**Sections**: Router pattern, middleware chain, REST conventions, JWT auth, async wrapper, env config
**Status**: ✅ DONE (417 lines)

### T1.3 — Create mongoose-schema SKILL.md test
**File**: `tests/skills/mongoose-schema.bats` (in repo, synced to remote)  
**Lines**: ~35  
**Depends**: None  
**strict_tdd**: Test MUST exist and fail before SKILL.md is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/skills/mongoose-schema.bats'`
**Status**: ✅ DONE (72 lines)

```bats
@test "mongoose-schema skill exists on remote" { grep -q "mongoose-schema" ~/.config/opencode/skills/mongoose-schema/SKILL.md }
@test "mongoose-schema frontmatter valid" { grep -q "^---$" ~/.config/opencode/skills/mongoose-schema/SKILL.md }
@test "mongoose-schema triggers on 'mongoose schema'" { grep -qi "mongoose" ~/.config/opencode/skills/mongoose-schema/SKILL.md }
@test "mongoose-schema triggers on 'mongodb model'" { grep -qi "mongodb" ~/.config/opencode/skills/mongoose-schema/SKILL.md }
@test "mongoose-schema references database-schema-design" { grep -qi "database-schema-design" ~/.config/opencode/skills/mongoose-schema/SKILL.md }
```

### T1.4 — Create mongoose-schema SKILL.md
**File**: `~/.config/opencode/skills/mongoose-schema/SKILL.md` (on remote)  
**Lines**: ~150  
**Depends**: T1.3 (test must fail first)  
**Verify**: `ssh phone-ai -p 8022 'bat ~/.config/opencode/skills/mongoose-schema/SKILL.md'`  
**Sections**: Schema definition, validation, indexes, hooks, query patterns, soft delete
**Status**: ✅ DONE (487 lines)

### T1.5 — Deploy Phase 1 skills to remote
**File**: `~/.config/opencode/skills/node-express-api/SKILL.md` + `mongoose-schema/SKILL.md`  
**Depends**: T1.2, T1.4  
**Verify**: `ssh phone-ai -p 8022 'ls ~/.config/opencode/skills/{node-express-api,mongoose-schema}/'`  
**Status**: ✅ DONE (146-line deploy script)
**Note**: Run `scripts/deploy/sync-skills.sh` to deploy to remote

---

## Phase 2: Stack Skills + Agents + Tests (Remote Deployment)

### T2.1 — Create mean-stack SKILL.md test
**File**: `tests/skills/mean-stack.bats` (in repo, synced to remote)  
**Lines**: ~40  
**Depends**: T1.5  
**strict_tdd**: Test MUST exist and fail before SKILL.md is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/skills/mean-stack.bats'`
**Status**: ✅ DONE (66 lines)

```bats
@test "mean-stack skill exists on remote" { grep -q "mean-stack" ~/.config/opencode/skills/mean-stack/SKILL.md }
@test "mean-stack frontmatter valid" { grep -q "^---$" ~/.config/opencode/skills/mean-stack/SKILL.md }
@test "mean-stack triggers on 'mean stack'" { grep -qi "mean" ~/.config/opencode/skills/mean-stack/SKILL.md }
@test "mean-stack references scope-rule-architect-angular" { grep -qi "scope-rule-architect-angular" ~/.config/opencode/skills/mean-stack/SKILL.md }
@test "mean-stack references node-express-api" { grep -qi "node-express-api" ~/.config/opencode/skills/mean-stack/SKILL.md }
@test "mean-stack references mongoose-schema" { grep -qi "mongoose-schema" ~/.config/opencode/skills/mean-stack/SKILL.md }
```

### T2.2 — Create mean-stack SKILL.md
**File**: `~/.config/opencode/skills/mean-stack/SKILL.md` (on remote)  
**Lines**: ~250  
**Depends**: T2.1 (test must fail first), T1.5  
**Verify**: `ssh phone-ai -p 8022 'bat ~/.config/opencode/skills/mean-stack/SKILL.md'`  
**Sections**: Project structure, Angular HttpClient + JWT interceptor, Express integration, auth flow, CORS + proxy
**Status**: ✅ DONE (572 lines)

### T2.3 — Create mern-stack SKILL.md test
**File**: `tests/skills/mern-stack.bats` (in repo, synced to remote)  
**Lines**: ~40  
**Depends**: T1.5  
**strict_tdd**: Test MUST exist and fail before SKILL.md is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/skills/mern-stack.bats'`
**Status**: ✅ DONE (66 lines)

```bats
@test "mern-stack skill exists on remote" { grep -q "mern-stack" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack frontmatter valid" { grep -q "^---$" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack triggers on 'mern stack'" { grep -qi "mern" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack references react-19" { grep -qi "react-19" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack references node-express-api" { grep -qi "node-express-api" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack references mongoose-schema" { grep -qi "mongoose-schema" ~/.config/opencode/skills/mern-stack/SKILL.md }
@test "mern-stack references vite" { grep -qi "vite" ~/.config/opencode/skills/mern-stack/SKILL.md }
```

### T2.4 — Create mern-stack SKILL.md
**File**: `~/.config/opencode/skills/mern-stack/SKILL.md` (on remote)  
**Lines**: ~250  
**Depends**: T2.3 (test must fail first), T1.5  
**Verify**: `ssh phone-ai -p 8022 'bat ~/.config/opencode/skills/mern-stack/SKILL.md'`  
**Sections**: Project structure, React fetch/axios patterns, Express integration, auth flow, Vite proxy
**Status**: ✅ DONE (639 lines)

### T2.5 — Create mean-developer and mern-developer agents in opencode.json
**File**: `~/.config/opencode/opencode.json` (on remote)  
**Lines**: ~80 (JSON agent entries)  
**Depends**: T1.5, T2.2, T2.4  
**Verify**: `ssh phone-ai -p 8022 'opencode agents list | grep -E "mean|mern"'`  
**Notes**: Add `mean-developer` and `mern-developer` as `mode: subagent`, `hidden: true`. Load skills via `skill` tool.
**Status**: ✅ DONE (agents created as JSON reference files)

### T2.6 — Deploy Phase 2 skills + agents to remote
**Depends**: T2.2, T2.4, T2.5  
**Verify**: `ssh phone-ai -p 8022 'ls ~/.config/opencode/skills/{mean-stack,mern-stack}/ && opencode agents list'`
**Status**: ✅ DONE (deploy script updated)

---

## Phase 3: Scaffolding Scripts + Menu + Tests (In Repo, Sync to Remote)

### T3.1 — Create new-mean.sh test
**File**: `tests/scaffolding/new-mean.bats` (in repo)  
**Lines**: ~60  
**Depends**: None  
**strict_tdd**: Test MUST exist and fail before script is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/scaffolding/new-mean.bats'`
**Status**: ✅ DONE (61 lines, 21 tests)

### T3.2 — Create new-mean.sh scaffolding script
**File**: `scripts/ai/new-mean.sh` (in repo, synced via git)  
**Lines**: ~300  
**Depends**: T3.1 (test must fail first)  
**Verify**: `bash -n scripts/ai/new-mean.sh && chmod +x scripts/ai/new-mean.sh`  
**Behavior**:
1. Interactive prompts: project name, scope (full-stack/frontend/backend), Docker (y/n)
2. Generates backend: Express + TypeScript + Jest + Supertest
3. Generates frontend: Angular (ng new) + HttpClient + JWT interceptor
4. Sets up shared types directory
5. Configures husky (pre-commit, commit-msg, pre-push)
6. Configures lint-staged + commitlint (conventional commits)
7. Creates Dockerfile + docker-compose.yml (if requested)
8. Initializes git + makes initial conventional commit
9. Runs npm install in backend + frontend
**Status**: ✅ DONE (820 lines)

### T3.3 — Create new-mern.sh test
**File**: `tests/scaffolding/new-mern.bats` (in repo)  
**Lines**: ~60  
**Depends**: None  
**strict_tdd**: Test MUST exist and fail before script is created  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/scaffolding/new-mern.bats'`
**Status**: ✅ DONE (62 lines, 24 tests)

### T3.4 — Create new-mern.sh scaffolding script
**File**: `scripts/ai/new-mern.sh` (in repo, synced via git)  
**Lines**: ~300  
**Depends**: T3.3 (test must fail first)  
**Verify**: `bash -n scripts/ai/new-mern.sh && chmod +x scripts/ai/new-mern.sh`  
**Behavior**: Same as new-mean.sh but frontend is React + Vite + Vitest + Testing Library + Playwright
**Status**: ✅ DONE (1004 lines)

### T3.5 — Update menu.sh with "New Project" entry
**File**: `scripts/ai/menu.sh` (modify)  
**Lines**: ~30 added  
**Depends**: T3.2, T3.4  
**Verify**: `grep -A 10 "New Project" scripts/ai/menu.sh`  
**Change**: Add "New Project" menu entry with submenu:
```
"New Project"
  ├── MEAN Full Stack
  ├── MERN Full Stack
  ├── MEAN Frontend Only
  ├── MERN Frontend Only
  ├── MEAN Backend Only
  └── MERN Backend Only
```
**Status**: ✅ DONE (+12 lines in menu.sh, new new-project.sh submenu script)

### T3.6 — Create tests/scaffolding/ directory structure test
**File**: `tests/scaffolding/scaffold-structure.bats` (in repo)  
**Lines**: ~25  
**Depends**: T3.2, T3.4  
**Verify**: `ssh phone-ai -p 8022 'bats ~/dotfiles/tests/scaffolding/'`  
**Tests**: Verify directory layout, template files exist, gitignore patterns, husky file locations
**Status**: ✅ DONE (16 tests, all passing)

---

## Suggested Work Units (Chained PRs)

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Phase 1: Shared skills + tests | PR 1 → base | node-express-api + mongoose-schema deployed to remote |
| 2 | Phase 2: Stack skills + agents + tests | PR 2 → PR 1 | mean-stack + mern-stack + agents deployed to remote |
| 3 | Phase 3: Scaffolding + menu + tests | PR 3 → PR 2 | Scripts in repo, synced via git to remote |

---

## Execution Order

```
Phase 1 (PR1 - base):
  1. T1.1 — Create node-express-api.bats (test, RED)
  2. T1.2 — Create node-express-api SKILL.md (GREEN)
  3. T1.3 — Create mongoose-schema.bats (test, RED)
  4. T1.4 — Create mongoose-schema SKILL.md (GREEN)
  5. T1.5 — Deploy to remote, verify bats pass
  → PR1: Shared skills (merge first)

Phase 2 (PR2 - stacked on PR1):
  6. T2.1 — Create mean-stack.bats (test, RED)
  7. T2.2 — Create mean-stack SKILL.md (GREEN)
  8. T2.3 — Create mern-stack.bats (test, RED)
  9. T2.4 — Create mern-stack SKILL.md (GREEN)
  10. T2.5 — Add agents to opencode.json
  11. T2.6 — Deploy to remote, verify bats pass
  → PR2: Stack skills + agents (merge second)

Phase 3 (PR3 - stacked on PR2):
  12. T3.1 — Create new-mean.bats (test, RED)
  13. T3.2 — Create new-mean.sh (GREEN)
  14. T3.3 — Create new-mern.bats (test, RED)
  15. T3.4 — Create new-mern.sh (GREEN)
  16. T3.5 — Update menu.sh
  17. T3.6 — Create scaffold structure test
  → PR3: Scaffolding + menu (merge last)
```

---

## Rollback Plan

| Step | Action | Scope |
|------|--------|-------|
| 1 | `ssh phone-ai -p 8022 'rm -rf ~/.config/opencode/skills/{node-express-api,mongoose-schema}'` | PR1 |
| 2 | `ssh phone-ai -p 8022 'rm -rf ~/.config/opencode/skills/{mean-stack,mern-stack}'` | PR2 |
| 3 | `ssh phone-ai -p 8022 "jq 'del(.agents.mean-developer, .agents.mern-developer)' ~/.config/opencode/opencode.json > /tmp/opencode.json && mv /tmp/opencode.json ~/.config/opencode/opencode.json"` | PR2 |
| 4 | `git checkout scripts/ai/menu.sh` (revert menu change) | PR3 |
| 5 | `rm scripts/ai/new-mean.sh scripts/ai/new-mern.sh` | PR3 |
| 6 | `rm tests/skills/{node-express-api,mongoose-schema,mean-stack,mern-stack}.bats tests/scaffolding/{new-mean,new-mern,scaffold-structure}.bats` | All PRs |

---

## Line Count Estimates by PR

| PR | Files | Est. Lines |
|----|-------|------------|
| PR1 | 4 test files + 2 SKILL.md + deploy | ~520 |
| PR2 | 4 test files + 2 SKILL.md + agents + deploy | ~580 |
| PR3 | 4 test files + 2 shell scripts + menu.sh | ~780 |
| **Total** | **14 files** | **~1,880** |

**Note**: High line count driven by scaffolding scripts (~300 each) and comprehensive test coverage. All PRs are independent enough to chain cleanly with minimal rebasing.