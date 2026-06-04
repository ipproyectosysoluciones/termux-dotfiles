---
change: Docker-PS
status: tasks
---

# SDD Tasks: Docker-PS

## Context

Read spec at `openspec/changes/Docker-PS/spec.md` and design at `openspec/changes/Docker-PS/design.md`.

## Change Summary

Create complete Docker workflow in AI Workspace. 5 deliverables:
1. **Wrapper docker** in `scripts/debian/wrappers.sh` — add `create_wrapper docker` after kubernetes section
2. **Bootstrap** `scripts/debian/bootstrap/docker.sh` — install docker.io in proot debian
3. **Infra template** `scripts/ai/templates/infra.sh` — build_layout() creating server/editor/claude/gemini windows
4. **Enhanced launcher** `scripts/ai/docker.sh` — add proot-distro check, session management
5. **Tests + Docs** — bats tests per deliverable with strict TDD

## Constraints

- **strict_tdd: true** — tests must fail before implementation, pass after
- **Delivery strategy: force-chained** — split into 3 chained PRs
- **Review budget: 400 lines total**
- **Artifact store: both** — OpenSpec files + Engram

---

## Task List

### DPS-T1: Docker Wrapper in wrappers.sh

**PR**: PR1  
**Dependencies**: None  
**Files**:
- `scripts/debian/wrappers.sh` (modify — add `create_wrapper docker` after kubernetes section)

**Acceptance Criteria**:
- [ ] `create_wrapper docker` called after `create_wrapper helm` in wrappers.sh
- [ ] Wrapper installed at `~/.local/bin/docker` when wrappers.sh runs
- [ ] Wrapper shebang: `#!/data/data/com.termux/files/usr/bin/bash`
- [ ] Wrapper contains `/etc/debian_version` check for direct execution
- [ ] Wrapper routes through `proot-distro login debian` when outside debian
- [ ] Wrapper contains `--bind $HOME:/termux` and `--user dev` flags
- [ ] Wrapper passes all arguments via `"$@"`
- [ ] Wrapper is executable (chmod +x)

**Test Approach**:
- File: `tests/phaseN/docker_wrapper.bats`
- Tests verify wrapper file existence, executability, and content patterns using grep
- Tests MUST fail before `create_wrapper docker` is added to wrappers.sh

**Estimated Lines**: ~15

---

### DPS-T2: Docker Bootstrap Script

**PR**: PR1  
**Dependencies**: DPS-T1 (wrapper must exist for bootstrap to work)  
**Files**:
- `scripts/debian/bootstrap/docker.sh` (create)

**Acceptance Criteria**:
- [ ] Script uses `#!/bin/bash` shebang
- [ ] Script uses `set -euo pipefail`
- [ ] Has DEPENDENCIES section with `apt install -y curl ca-certificates`
- [ ] Has DOCKER section with `apt install -y docker.io`
- [ ] Has VERIFY section with `docker --version`
- [ ] Idempotent: exits 0 if docker already installed
- [ ] Reports installation progress with echo markers
- [ ] Exits 0 on success, exits 1 on failure

**Test Approach**:
- File: `tests/phaseN/docker_bootstrap.bats`
- Tests verify file existence, shebang, set -euo pipefail, section markers, and install commands
- Tests MUST fail before bootstrap/docker.sh is created

**Estimated Lines**: ~35

---

### DPS-T3: Infra Template for Docker Projects

**PR**: PR2  
**Dependencies**: DPS-T2 (bootstrap provides docker in debian)  
**Files**:
- `scripts/ai/templates/infra.sh` (create)

**Acceptance Criteria**:
- [ ] Script uses `#!/data/data/com.termux/files/usr/bin/bash` shebang
- [ ] Exports `build_layout()` function taking session name as `$1`
- [ ] Creates "server" window running `docker ps`
- [ ] Creates "editor" window running `nvim`
- [ ] Creates "claude" window running `claude`
- [ ] Creates "gemini" window running `gemini`
- [ ] Selects "editor" window as active with `tmux select-window`
- [ ] Mirrors node.sh structure (tmux new-window, tmux send-keys patterns)
- [ ] Follows layout.sh case mapping: `docker` → `infra`

**Test Approach**:
- File: `tests/phaseN/docker_infra_template.bats`
- Tests verify file existence, shebang, build_layout function export, and window creation commands
- Tests MUST fail before infra.sh is created

**Estimated Lines**: ~40

---

### DPS-T4: Enhanced Docker Launcher

**PR**: PR3  
**Dependencies**: DPS-T1, DPS-T3 (wrapper and template ready)  
**Files**:
- `scripts/ai/docker.sh` (modify)

**Acceptance Criteria**:
- [ ] Sources `$SCRIPT_DIR/utils.sh` for create_session and attach_or_switch
- [ ] Checks proot-distro availability: `proot-distro status debian`
- [ ] Exits 1 with helpful message if proot-distro unavailable
- [ ] Checks docker wrapper exists: `command -v docker`
- [ ] Exits 1 with helpful message if wrapper not found
- [ ] Creates tmux session named "docker" via `create_session`
- [ ] Attaches to session via `attach_or_switch`
- [ ] No regression: existing docker.sh behavior preserved where compatible

**Test Approach**:
- File: `tests/phaseN/docker_launcher.bats`
- Tests verify proot-distro check, utils.sh sourcing, create_session/attach_or_switch usage
- Tests MUST fail before enhancements are added to docker.sh

**Estimated Lines**: ~25

---

### DPS-T5: TDD Tests for All Deliverables

**PR**: PR1 (wrapper + bootstrap tests), PR2 (infra tests), PR3 (launcher tests + docs)  
**Dependencies**: None (tests created first per strict TDD)  
**Files**:
- `tests/phaseN/docker_wrapper.bats`
- `tests/phaseN/docker_bootstrap.bats`
- `tests/phaseN/docker_infra_template.bats`
- `tests/phaseN/docker_launcher.bats`

**Acceptance Criteria**:
- [ ] All test files use `setup()` with PROJECT_ROOT and SCRIPT_DIR
- [ ] All tests use `@test` annotation with clear behavior names
- [ ] All tests use load statement for test_helper.bash
- [ ] Tests use grep to verify file content patterns (no mock-only tests)
- [ ] Tests run with `bats --recursive tests/phaseN/docker_*.bats`
- [ ] No regression: existing tests still pass

**Test Approach**:
- Tests created FIRST (strict TDD) — must fail before implementation
- Tests verify real file content, not mocks
- Each test file follows existing bats conventions from project

**Estimated Lines**: ~120 (across 4 test files)

---

## Chained PR Structure

| PR | Focus | Tasks | Est. Lines |
|----|-------|-------|------------|
| **PR1** | Wrapper + Bootstrap | DPS-T1, DPS-T2, DPS-T5 (partial) | ~80 |
| **PR2** | Infra Template | DPS-T3, DPS-T5 (partial) | ~60 |
| **PR3** | Launcher + Tests + Docs | DPS-T4, DPS-T5 (partial) | ~120 |

### PR1: Wrapper + Bootstrap (~80 lines)

**Branch**: `feat/docker-wrapper-bootstrap`

**Changes**:
```
scripts/debian/wrappers.sh        (+6 lines: create_wrapper docker)
scripts/debian/bootstrap/docker.sh (+45 lines: new file)
tests/phaseN/docker_wrapper.bats  (+30 lines: new file)
tests/phaseN/docker_bootstrap.bats (+35 lines: new file)
```

**Chain Position**: Base of chain

---

### PR2: Infra Template (~60 lines)

**Branch**: `feat/docker-infra-template` (from PR1)

**Changes**:
```
scripts/ai/templates/infra.sh    (+45 lines: new file)
tests/phaseN/docker_infra_template.bats (+40 lines: new file)
```

**Chain Position**: Child of PR1

---

### PR3: Launcher + Tests + Docs (~120 lines)

**Branch**: `feat/docker-launcher-tests` (from PR2)

**Changes**:
```
scripts/ai/docker.sh             (+25 lines: proot-distro check + session)
tests/phaseN/docker_launcher.bats (+40 lines: new file)
README.md or docs/                (+30 lines: docker workflow docs)
```

**Chain Position**: Child of PR2

---

## Review Workload Forecast

### Total Estimated Changed Lines

| PR | Files | Est. Lines |
|----|-------|------------|
| PR1 | 4 files | ~80 |
| PR2 | 2 files | ~60 |
| PR3 | 3 files | ~120 |
| **Total** | **9 files** | **~260** |

### Chained PRs Recommended?

**YES**. Even though total (~260 lines) is under the 400-line budget, the change has 4 independent work units (wrapper, bootstrap, template, launcher) that map cleanly to 3 chained PRs. The chained structure:

1. Reduces per-PR review cognitive load
2. Allows independent verification of each deliverable
3. Follows user's explicit `force-chained` delivery strategy

### Decision Needed Before Apply

1. **PR1 first** — approve wrapper + bootstrap before starting infra template?
2. **Remote test execution** — confirm `ssh phone-ai -p 8022` access for bats tests
3. **Phase number** — which phase should the test directory be? (phase5 is next based on existing structure)

---

## Execution Order

```
1. DPS-T5 (tests)  → tests/phaseN/docker_wrapper.bats + docker_bootstrap.bats
2. DPS-T1 (impl)    → wrappers.sh add create_wrapper docker
3. DPS-T5 (tests)  → verify wrapper tests pass
4. DPS-T2 (impl)   → bootstrap/docker.sh
5. DPS-T5 (tests)  → verify bootstrap tests pass
6. PR1 created     → wrapper + bootstrap (merge first)
7. DPS-T5 (tests)  → tests/phaseN/docker_infra_template.bats
8. DPS-T3 (impl)   → templates/infra.sh
9. PR2 created     → infra template (merge second)
10. DPS-T5 (tests) → tests/phaseN/docker_launcher.bats
11. DPS-T4 (impl)  → docker.sh enhancements
12. PR3 created    → launcher + tests + docs (merge last)
```

---

## Rollback Plan

| Step | Action | PR |
|------|--------|-----|
| 1 | `git checkout scripts/debian/wrappers.sh` (remove create_wrapper docker) | PR1 |
| 2 | `rm scripts/debian/bootstrap/docker.sh` | PR1 |
| 3 | `rm scripts/ai/templates/infra.sh` | PR2 |
| 4 | `git checkout scripts/ai/docker.sh` | PR3 |
| 5 | `rm tests/phaseN/docker_*.bats` | PR1/2/3 |
| 6 | `bats --recursive tests/` — verify no regressions | — |

---

## Key Discoveries

1. **Layout routing**: `layout.sh` already maps `docker` project type to `infra` layout via `case docker: echo "infra"`
2. **Existing patterns**: kubectl/helm wrappers already use same `create_wrapper` pattern
3. **Bootstrap pattern**: kubernetes.sh shows DEPENDENCIES/DOCKER/VERIFY structure
4. **Template pattern**: node.sh shows build_layout() structure with server/editor/claude/gemini windows
5. **Utils pattern**: create_session + attach_or_switch already exist in utils.sh

---

## Test Execution Commands

```bash
# Run docker tests on remote device
ssh phone-ai -p 8022 'cd termux-dotfiles && bats --recursive tests/phaseN/docker_*.bats'

# Run specific test file
ssh phone-ai -p 8022 'cd termux-dotfiles && bats tests/phaseN/docker_wrapper.bats'

# Verify wrapper exists
ssh phone-ai -p 8022 'ls -la ~/.local/bin/docker'

# Verify proot-distro docker works
ssh phone-ai -p 8022 'proot-distro login debian -- docker --version'
```