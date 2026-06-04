---
change: Docker-PS
status: design
---

# SDD Design: Docker-PS

## Context

This design creates a complete Docker workflow in AI Workspace. Docker CLI must route through proot-distro debian because Termux lacks native Docker daemon. The implementation follows existing patterns (kubectl/helm wrappers, kubernetes.sh bootstrap, node.sh template).

## Component Architecture

```
Termux Shell
    │
    ├─ wrappers.sh ──────────────────────────► ~/.local/bin/docker (wrapper script)
    │       │                                       │
    │       │                                       ├─ /etc/debian_version exists?
    │       │                                       │   ├─ YES: exec docker "$@"
    │       │                                       │   └─ NO: proot-distro login debian --bind $HOME:/termux --user dev
    │       │
    │       └─ create_wrapper docker               │
    │                                               │
    ├─ bootstrap/docker.sh ◄───────────────────────┘
    │       │
    │       └─ proot-distro login debian -- apt install docker.io
    │
    └─ scripts/ai/docker.sh ◄─────────────────────── (enhanced launcher)
            │
            ├─ proot-distro availability check
            ├─ create_session "docker"
            └─ attach_or_switch "docker"

layout.sh ──► select_layout("docker") ──► echo "infra"
                │
                └─ apply_layout ──► source templates/infra.sh
                                        │
                                        └─ build_layout "$session"
```

## Data Flow

### Wrapper Flow (Termux → Debian → Docker Daemon)

```
1. User types: docker ps
2. Shell alias/PATH: ~/.local/bin/docker
3. Wrapper shebang: #!/data/data/com.termux/files/usr/bin/bash
4. Check: if [[ -f /etc/debian_version ]]; then exec docker "$@"
5. Outside debian: exec proot-distro login debian \
                       --bind $HOME:/termux \
                       --user dev -- \
                       env PATH=... \
                       docker "$@"
6. Inside debian: docker ps (直接执行，连接 /var/run/docker.sock)
```

### Bootstrap Flow

```
1. proot-distro login debian
2. apt update && apt install -y docker.io
3. docker --version 验证
4. Idempotent check: command -v docker && exit 0 || install
```

### Launcher Flow

```
1. docker.sh sourced
2. proot-distro availability check: proot-distro status debian
3. If unavailable: echo error + exit 1
4. create_session "docker" "docker ps"
5. attach_or_switch "docker"
```

## Interface Contracts

### 1. Wrapper (scripts/debian/wrappers.sh)

**Function**: `create_wrapper name`

**Input**:
- `name`: string (docker, kubectl, etc.)

**Output**:
- File: `$HOME/.local/bin/$name`
- Permissions: 0755 (executable)
- Content: heredoc with proot-distro invocation

**Behavior**:
```bash
# Inside debian detection
if [[ -f /etc/debian_version ]]; then
    exec $name "\$@"
fi

# Outside routing
exec proot-distro login debian \
    --bind \$HOME:/termux \
    --user dev -- \
    env PATH="..." \
    $name "\$@"
```

### 2. Bootstrap (scripts/debian/bootstrap/docker.sh)

**Functions**:
- `install_docker_dependencies()` — apt install curl ca-certificates
- `install_docker()` — apt install docker.io
- `verify_docker_installation()` — docker --version

**Input**: None (runs inside proot-distro debian)

**Output**: Exit 0 on success, exit 1 on failure

**Pattern** (follows kubernetes.sh):
```bash
#!/bin/bash
set -euo pipefail

echo "[debian] Installing Docker..."

########################################
# DEPENDENCIES
########################################

apt install -y curl ca-certificates

########################################
# DOCKER
########################################

apt install -y docker.io

########################################
# VERIFY
########################################

docker --version
echo "[debian] Docker installed"
```

### 3. Infra Template (scripts/ai/templates/infra.sh)

**Function**: `build_layout session`

**Input**:
- `session`: tmux session name string

**Output**: tmux windows (server, editor, claude, gemini)

**Pattern** (mirrors node.sh):
```bash
#!/data/data/com.termux/files/usr/bin/bash

build_layout() {
    local session="$1"

    tmux rename-window -t "$session:0" "server"
    tmux send-keys -t "$session:server" "docker ps" C-m

    tmux new-window -t "$session" -n "editor"
    tmux send-keys -t "$session:editor" "nvim" C-m

    tmux new-window -t "$session" -n "claude"
    tmux send-keys -t "$session:claude" "claude" C-m

    tmux new-window -t "$session" -n "gemini"
    tmux send-keys -t "$session:gemini" "gemini" C-m

    tmux select-window -t "$session:editor"
}
```

### 4. Enhanced Docker Launcher (scripts/ai/docker.sh)

**Input**: None (launcher)

**Output**: tmux session "docker" attached

**Pattern**:
```bash
#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

########################################
# PROOT-DISTRO CHECK
########################################

if ! proot-distro status debian > /dev/null 2>&1; then
    echo "[docker] proot-distro debian not available"
    echo "[docker] Run: proot-distro install debian"
    exit 1
fi

########################################
# SESSION
########################################

SESSION="docker"

if ! command -v docker > /dev/null 2>&1; then
    echo "[docker] docker wrapper not found"
    echo "[docker] Run: bash scripts/debian/wrappers.sh"
    exit 1
fi

create_session "$SESSION" "docker ps"
attach_or_switch "$SESSION"
```

## Error Handling

| Scenario | Detection | Action |
|----------|-----------|--------|
| proot-distro not installed | `proot-distro status debian` fails | Exit 1 with "Run: proot-distro install debian" |
| debian not configured | `/etc/debian_version` missing inside wrapper | Wrapper routes through proot-distro automatically |
| docker.io not installed | `command -v docker` fails inside debian | Bootstrap installs it |
| docker.sock not accessible | `docker ps` fails with socket error | Show socket path and suggest bootstrap |
| wrapper not created | `~/.local/bin/docker` not found | Show "Run: bash scripts/debian/wrappers.sh" |
| tmux not running | `tmux has-session` fails | create_session handles this |
| session already exists | tmux returns exit code | attach_or_switch switches to it |

## Testing Strategy

### Test File Structure

```
tests/phaseN/
  ├── docker_wrapper.bats
  ├── docker_bootstrap.bats
  ├── docker_launcher.bats
  └── docker_infra_template.bats
```

### Test Conventions (follow existing bats patterns)

```bash
setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}

teardown() {
    true
}

@test "wrapper docker creates executable at ~/.local/bin/docker" {
    # Verify file exists and is executable
    [[ -x "$HOME/.local/bin/docker" ]]
}

@test "wrapper docker contains proot-distro login debian" {
    run grep 'proot-distro login debian' "$HOME/.local/bin/docker"
    [[ "$status" -eq 0 ]]
}
```

### Component Test Coverage

**Wrapper Tests** (docker_wrapper.bats):
- [ ] `~/.local/bin/docker` exists
- [ ] `~/.local/bin/docker` is executable (0755)
- [ ] Contains `/etc/debian_version` check
- [ ] Contains `proot-distro login debian`
- [ ] Contains `--bind $HOME:/termux`
- [ ] Contains `--user dev`
- [ ] Passes arguments with `"$@"`
- [ ] PATH includes expected directories

**Bootstrap Tests** (docker_bootstrap.bats):
- [ ] File exists at `scripts/debian/bootstrap/docker.sh`
- [ ] Uses `set -euo pipefail`
- [ ] Has DEPENDENCIES section
- [ ] Has DOCKER section
- [ ] Has VERIFY section
- [ ] Installs `docker.io` via apt
- [ ] Verifies with `docker --version`
- [ ] Idempotent (check then install pattern)

**Template Tests** (docker_infra_template.bats):
- [ ] File exists at `scripts/ai/templates/infra.sh`
- [ ] Exports `build_layout` function
- [ ] Takes session argument
- [ ] Creates "server" window
- [ ] Creates "editor" window
- [ ] Creates "claude" window
- [ ] Creates "gemini" window
- [ ] Selects "editor" window
- [ ] Mirrors node.sh structure

**Launcher Tests** (docker_launcher.bats):
- [ ] Sources `utils.sh`
- [ ] Checks proot-distro availability
- [ ] Exits 1 if proot-distro unavailable
- [ ] Uses `create_session` helper
- [ ] Uses `attach_or_switch` helper
- [ ] Creates session named "docker"

### Execution Commands

```bash
# All docker tests
bats --recursive tests/phaseN/docker_*.bats

# Specific component
bats tests/phaseN/docker_wrapper.bats

# With verbose output
bats --formatter tap tests/phaseN/docker_*.bats
```

## Work Units (Commits)

| # | Work Unit | Files | Lines (est.) |
|---|-----------|-------|--------------|
| 1 | wrapper | wrappers.sh + tests | ~15 |
| 2 | bootstrap | bootstrap/docker.sh + tests | ~35 |
| 3 | template | templates/infra.sh + tests | ~40 |
| 4 | launcher | docker.sh + tests | ~25 |
| 5 | verify | run full suite | - |

**Total estimated**: ~115 lines (well under 400-line budget)

## Rollback Plan

| Step | Action |
|------|--------|
| 1 | `rm ~/.local/bin/docker` — remove wrapper |
| 2 | `rm scripts/debian/bootstrap/docker.sh` — remove bootstrap |
| 3 | `rm scripts/ai/templates/infra.sh` — remove template |
| 4 | `git checkout scripts/ai/docker.sh` — revert launcher |
| 5 | `rm tests/phaseN/docker_*.bats` — remove tests |
| 6 | `bats --recursive tests/` — verify no regressions |

## Key Decisions

1. **Wrapper pattern**: Already exists in wrappers.sh — just add `create_wrapper docker` after kubernetes section
2. **Bootstrap follows kubernetes.sh**: DEPENDENCIES/DOCKER/VERIFY sections for consistency
3. **Infra template mirrors node.sh**: Same tmux API calls, same window structure (server/editor/claude/gemini)
4. **Launcher enhances existing docker.sh**: Add proot-distro check without removing existing session management
5. **Tests use existing bats conventions**: setup/teardown pattern, grep-based verification