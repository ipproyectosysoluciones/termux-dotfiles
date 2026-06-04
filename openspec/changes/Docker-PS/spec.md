---
change: Docker-PS
status: draft
---

# SDD Spec: Docker-PS

## Context

Create a complete Docker workflow in AI Workspace: wrapper to route docker CLI through proot-distro debian, bootstrap installer, infra template (referenced by layout.sh but missing), enhanced launcher, TDD tests, and documentation.

## Deliverables

### 1. Wrapper docker (`scripts/debian/wrappers.sh`)

**Capability**: Routes `docker` CLI through proot-distro debian, mirroring the existing `kubectl`/`helm` pattern. Enables running `docker ps` from Termux and having it execute inside debian.

**Scenarios**:
- **Success**: `~/.local/bin/docker ps` routes through proot-distro and returns container list
- **Already inside debian**: Wrapper detects `/etc/debian_version` and executes directly
- **Docker not installed in debian**: Bootstrap script installs it; wrapper works after bootstrap

**Acceptance Criteria**:
- [ ] `create_wrapper docker` is called after kubernetes section in `wrappers.sh`
- [ ] Wrapper is installed at `~/.local/bin/docker`
- [ ] Wrapper is executable (`chmod +x`)
- [ ] Wrapper contains proot-distro login invocation with `--bind` and `--user dev`

**Test Scenarios**:
```bash
@test "wrapper docker creates executable at ~/.local/bin/docker"
@test "wrapper docker contains proot-distro login debian"
@test "wrapper docker contains /etc/debian_version check for direct execution"
@test "wrapper docker passes all arguments through with \"\$@\""
```

---

### 2. Bootstrap docker (`scripts/debian/bootstrap/docker.sh`)

**Capability**: Installs `docker.io` package inside proot-distro debian, including verifying daemon availability and socket path.

**Scenarios**:
- **Success**: `apt install docker.io -y` succeeds, `docker --version` prints version
- **Already installed**: Script idempotent; exits 0 if docker already present
- **No apt**: Falls back to manual installation or reports error

**Acceptance Criteria**:
- [ ] Installs `docker.io` package via apt in debian
- [ ] Verifies `docker --version` inside debian after install
- [ ] Idempotent: exits 0 if docker already installed
- [ ] Reports docker.sock path availability
- [ ] Follows pattern of `kubernetes.sh` (set -euo pipefail, echo markers, verify section)

**Test Scenarios**:
```bash
@test "docker.sh contains apt install docker.io"
@test "docker.sh verifies with docker --version"
@test "docker.sh is idempotent (check then install pattern)"
@test "docker.sh uses set -euo pipefail"
@test "docker.sh has DEPENDENCIES, DOCKER, VERIFY sections"
```

---

### 3. Infra template (`scripts/ai/templates/infra.sh`)

**Capability**: Layout template for infrastructure/DevOps projects. Referenced by `layout.sh` when `project_type == "docker"` (case maps to "infra"). Follows `node.sh` pattern with `build_layout()` function.

**Scenarios**:
- **Success**: `layout.sh` sources `infra.sh`, calls `build_layout "$session"`, creates tmux session with docker environment
- **Missing template**: Without this, `layout.sh` falls through to `default.sh` — wrong layout for docker projects

**Acceptance Criteria**:
- [ ] `infra.sh` exists at `scripts/ai/templates/infra.sh`
- [ ] Exports `build_layout()` function taking session name as argument
- [ ] Creates "server" window running docker context/pods
- [ ] Creates "editor" window with nvim
- [ ] Creates "claude" window with claude
- [ ] Creates "gemini" window with gemini
- [ ] Selects "editor" window as active
- [ ] Mirrors `node.sh` structure and tmux API calls

**Test Scenarios**:
```bash
@test "infra.sh exists at scripts/ai/templates/infra.sh"
@test "infra.sh exports build_layout function"
@test "infra.sh creates server window with docker context"
@test "infra.sh creates editor window with nvim"
@test "infra.sh creates claude and gemini windows"
@test "infra.sh selects editor window as active"
@test "layout.sh case docker sources infra.sh without error"
```

---

### 4. Enhanced docker launcher (`scripts/ai/docker.sh`)

**Capability**: Enhanced launcher that routes docker commands through proot-distro debian instead of raw termux docker. Creates dedicated tmux session.

**Scenarios**:
- **Success**: `docker.sh` checks proot-distro availability, routes through debian, creates tmux session, attaches
- **Docker not in debian**: Reports missing and suggests running bootstrap
- **No proot-distro**: Falls back to termux docker with warning

**Acceptance Criteria**:
- [ ] Checks `proot-distro login debian` availability before proceeding
- [ ] Routes docker commands through proot-distro debian
- [ ] Creates tmux session named "docker"
- [ ] Uses `create_session` and `attach_or_switch` from `utils.sh`
- [ ] Shows appropriate error if proot-distro unavailable
- [ ] Follows pattern of other launchers (ai.sh, node.sh)

**Test Scenarios**:
```bash
@test "docker.sh checks proot-distro availability"
@test "docker.sh sources utils.sh"
@test "docker.sh creates session named docker"
@test "docker.sh uses create_session helper"
@test "docker.sh uses attach_or_switch helper"
@test "docker.sh exits 1 if proot-distro unavailable with helpful message"
```

---

### 5. TDD Tests with bats

**Capability**: Strict TDD tests using bats framework. Tests written BEFORE implementation. Each deliverable has corresponding test file.

**Test Files**:
- `tests/phaseN/docker_wrapper.bats` — tests for wrapper creation
- `tests/phaseN/docker_bootstrap.bats` — tests for bootstrap script
- `tests/phaseN/docker_launcher.bats` — tests for enhanced launcher
- `tests/phaseN/docker_infra_template.bats` — tests for infra.sh template

**Scenarios**:
- **Strict TDD**: Each test fails before implementation, passes after
- **No mock-only tests**: Tests verify real behavior against actual files
- **Tests with code**: Each deliverable commit includes its tests

**Acceptance Criteria**:
- [ ] Each test file has setup() with PROJECT_ROOT and SCRIPT_DIR
- [ ] All tests use `@test` annotation with clear names describing behavior
- [ ] Tests run with `bats --recursive tests/`
- [ ] No regression: existing tests still pass
- [ ] Tests match project conventions (grep for patterns in source files)

**Test Scenarios**:
```bash
@test "docker wrapper installs at ~/.local/bin/docker"
@test "docker wrapper is executable"
@test "docker wrapper contains proot-distro invocation"
@test "docker bootstrap uses set -euo pipefail"
@test "docker bootstrap installs docker.io"
@test "docker bootstrap is idempotent"
@test "infra template exists"
@test "infra template exports build_layout function"
@test "docker launcher checks proot-distro"
@test "docker launcher uses create_session"
```

---

## Implementation Order (Work Units)

1. **wrapper**: Add `create_wrapper docker` to `wrappers.sh` + tests
2. **bootstrap**: Create `bootstrap/docker.sh` + tests
3. **template**: Create `templates/infra.sh` + tests
4. **launcher**: Enhance `docker.sh` + tests
5. **verify**: Run full bats suite, confirm no regressions

---

## Verification

```bash
# Run all docker tests
bats --recursive tests/phaseN/docker_*.bats

# Run specific test file
bats tests/phaseN/docker_wrapper.bats

# Verify wrapper exists and is executable
ls -la ~/.local/bin/docker

# Verify proot-distro docker works
proot-distro login debian -- docker --version

# Verify layout routing
# (requires project with docker in package.json or similar)
```

---

## Files to Modify/Create

| File | Action | Change |
|------|--------|--------|
| `scripts/debian/wrappers.sh` | Modify | Add `create_wrapper docker` after kubernetes section |
| `scripts/debian/bootstrap/docker.sh` | Create | Bootstrap docker.io installation |
| `scripts/ai/templates/infra.sh` | Create | Layout template for docker/infra projects |
| `scripts/ai/docker.sh` | Modify | Add proot-distro routing, session management |
| `tests/phaseN/docker_wrapper.bats` | Create | Wrapper tests |
| `tests/phaseN/docker_bootstrap.bats` | Create | Bootstrap tests |
| `tests/phaseN/docker_launcher.bats` | Create | Launcher tests |
| `tests/phaseN/docker_infra_template.bats` | Create | Template tests |

---

## Rollback Plan

1. `rm ~/.local/bin/docker` — removes wrapper, restores termux docker
2. `rm scripts/debian/bootstrap/docker.sh` — removes bootstrap
3. `rm scripts/ai/templates/infra.sh` — removes infra template
4. `git checkout scripts/ai/docker.sh` — reverts launcher changes
5. `rm tests/phaseN/docker_*.bats` — removes all docker tests
6. `bats --recursive tests/` — verify no regressions