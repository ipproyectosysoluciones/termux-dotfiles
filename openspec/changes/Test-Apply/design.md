# SDD Design: Test-Apply (AI Workspace TDD Coverage)

## Change ID
`Test-Apply`

## Intent
Design the technical architecture and approach for implementing comprehensive TDD test coverage for the AI Workspace framework using the bats framework.

---

## 1. Test Architecture

### 1.1 Enhanced `test_helper.bash`

The existing `tests/test_helper.bash` is minimal (7 lines). It MUST be extended to provide:

#### 1.1.1 Path Resolution Helpers

```bash
# Resolve script under test to absolute path
resolve_script() {
    local script_rel="$1"
    echo "$PROJECT_ROOT/$script_rel"
}

# Resolve provider script path
resolve_provider() {
    echo "$PROJECT_ROOT/scripts/ai/providers/$1.sh"
}

# Resolve core module path
resolve_core() {
    echo "$PROJECT_ROOT/scripts/ai/core/$1.sh"
}
```

#### 1.1.2 Mock Functions for Provider Binaries

```bash
# Mock gemini command
mock_gemini() {
    local response="${1:-"mock gemini response"}"
    local status="${2:-0}"
    export FAKE_GEMINI_RESPONSE="$response"
    export FAKE_GEMINI_STATUS="$status"
}

# Mock opencode command
mock_opencode() {
    local response="${1:-"mock opencode response"}"
    export FAKE_OPENCODE_RESPONSE="$response"
}

# Mock tmux commands
mock_tmux() {
    export FAKE_TMUX_SESSIONS="$1"  # comma-separated list
}
```

#### 1.1.3 Fixtures for Temporary Test Projects

```bash
# Create temporary project structure
create_test_project() {
    local dir="$1"
    local type="$2"  # git, node, python, docker, rust
    
    mkdir -p "$dir/subdir/nested"
    
    case "$type" in
        git)
            mkdir -p "$dir/.git"
            ;;
        node)
            echo '{"name":"test-project"}' > "$dir/package.json"
            ;;
        python)
            echo "pytest==7.0.0" > "$dir/requirements.txt"
            ;;
        docker)
            echo "version: '3'" > "$dir/docker-compose.yml"
            ;;
        rust)
            echo "[package]" > "$dir/Cargo.toml"
            echo "name = \"test\"" >> "$dir/Cargo.toml"
            ;;
    esac
}

# Cleanup temporary projects
cleanup_test_project() {
    local dir="$1"
    rm -rf "$dir"
}
```

#### 1.1.4 bats-mock Integration Pattern

Install `bats-mock` from `https://github.com/ztombol/bats-mock` for binary stubs:

```bash
# Create mock for a binary
create_mock() {
    local bin_name="$1"
    local mock_dir="$TEST_TMPDIR/mocks"
    mkdir -p "$mock_dir"
    
    # Write mock script
    cat > "$mock_dir/$bin_name" <<'MOCK'
#!/usr/bin/env bash
# Auto-generated mock for testing
if [[ -n "$FAKE_${bin_name^^}_RESPONSE" ]]; then
    echo "$FAKE_${bin_name^^}_RESPONSE"
    exit ${FAKE_${bin_name^^}_STATUS:-0}
fi
echo "mock $bin_name default output"
exit 0
MOCK
    chmod +x "$mock_dir/$bin_name"
}

# Add mock bin to PATH
add_mocks_to_path() {
    export PATH="$TEST_TMPDIR/mocks:$PATH"
}
```

### 1.2 Mock Strategy by Provider Type

#### 1.2.1 Gemini API Mock

```bash
# Mock curl that intercepts gemini API calls
mock_curl_for_gemini() {
    local response="$1"
    local quota_exhausted="${2:-false}"
    
    # shell function override via test setup
    curl() {
        if [[ "$*" == *"generativelanguage"* ]]; then
            if [[ "$quota_exhausted" == "true" ]]; then
                echo "QUOTA_EXHAUSTED"
            else
                echo "$response"
            fi
            return 0
        fi
        command curl "$@"
    }
}
```

#### 1.2.2 TMUX Mock

```bash
# Mock tmux has-session
tmux() {
    case "$1" in
        has-session)
            if echo "$FAKE_TMUX_SESSIONS" | grep -q "$2"; then
                return 0
            fi
            return 1
            ;;
        new-session)
            echo "mock: creating session $3"
            return 0
            ;;
        send-keys)
            echo "mock: sending keys to $3"
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}
```

#### 1.2.3 Provider Availability Mock

```bash
# Mock provider_available function
provider_available() {
    local provider="$1"
    case "$provider" in
        gemini)
            [[ "$FAKE_GEMINI_AVAILABLE" != "false" ]]
            ;;
        opencode)
            [[ "$FAKE_OPENCODE_AVAILABLE" != "false" ]]
            ;;
        claude)
            [[ "$FAKE_CLAUDE_AVAILABLE" != "false" ]]
            ;;
        gentle)
            [[ "$FAKE_GENTLE_AVAILABLE" != "false" ]]
            ;;
        mistral)
            [[ "$FAKE_MISTRAL_AVAILABLE" != "false" ]]
            ;;
        *)
            return 1
            ;;
    esac
}
```

### 1.3 Hardcoded Path Handling

#### 1.3.1 Dynamic ROOT Resolution via `BASH_SOURCE`

Tests MUST verify that scripts use `$(dirname "${BASH_SOURCE[0]}")` instead of hardcoded paths. The test helper provides:

```bash
# Simulate script execution from different installation paths
simulate_script_at() {
    local script_path="$1"
    local fake_installdir="$2"
    
    # Create temp symlink structure
    mkdir -p "$fake_installdir/scripts/ai"
    ln -sf "$PROJECT_ROOT/scripts/ai/"* "$fake_installdir/scripts/ai/"
    
    # Set HOME to fake install dir to test path resolution
    export HOME="$fake_installdir"
}
```

#### 1.3.2 State Directory Override

State-dependent scripts (state.sh, memory.sh) need `STATE_DIR` overridable:

```bash
setup() {
    # ... existing setup ...
    export STATE_DIR="$BATS_TEST_TMPDIR/state"
    export SYNC_ROOT="$BATS_TEST_TMPDIR/sync"
    export HOME="$BATS_TEST_TMPDIR"
}
```

---

## 2. File Structure

```
tests/
├── test_helper.bash                    # Shared test infrastructure (enhanced)
├── phase1/                              # Core module tests
│   ├── project_detection.bats           # detect_project, project_name, project_type, git_branch
│   ├── runtime_detection.bats          # detect_runtime, detect_tmux_mode, detect_network
│   ├── state_management.bats           # save/load/clear workspace state
│   ├── memory_integration.bats         # memory_available, memory_project_context, memory_search, memory_save
│   ├── hydration_context.bats          # build_context
│   ├── sync_operations.bats            # sync_project_path, mirror_project, provider_workspace, ensure_sync_root
│   ├── provider_selector.bats          # select_provider (all intent routing cases)
│   ├── agent_router.bats               # route_agent_provider (all agent routing cases)
│   ├── skill_detector.bats             # detect_skill (case-insensitive keyword matching)
│   └── skill_registry.bats            # load_skill_registry, skill_exists, list_skills
├── phase2/                              # Provider tests
│   ├── gemini_provider.bats            # run_gemini, QUOTA_EXHAUSTED fallback, generic failure fallback
│   ├── claude_provider.bats           # run_claude, env vars, missing binary
│   ├── opencode_provider.bats         # run_opencode, missing binary
│   └── gentle_provider.bats           # gentle_sync, gentle_upgrade, gentle_refresh_skills
├── phase3/                              # Integration tests
│   ├── main_entry_point.bats           # ai.sh bootstrap, detection, routing, doctor, resume
│   └── router_integration.bats        # run_provider dispatch to all providers
├── phase4/                              # Launcher and template tests
│   ├── menu_interaction.bats          # Menu choices, script invocation
│   ├── utils_functions.bats          # session_exists, attach_or_switch, create_session
│   ├── workspace_launcher.bats       # Template selection, layout application
│   └── templates.bats                 # default, mobile, node, remote build_layout functions
└── phase5/                              # Error path tests
    ├── error_empty_prompt.bats        # ai.sh with no arguments
    ├── error_missing_env.bats         # Provider sourcing without .env
    ├── error_no_tmux.bats             # TMUX unavailable handling
    ├── error_network_offline.bats     # detect_network returns offline
    └── error_missing_binary.bats      # Provider fallback chains with missing binary
```

### 2.1 Directory Creation Commands

```bash
# Create all phase directories
mkdir -p tests/phase1 tests/phase2 tests/phase3 tests/phase4 tests/phase5

# All phase directories need .gitkeep to ensure directory structure is preserved
touch tests/phase1/.gitkeep tests/phase2/.gitkeep tests/phase3/.gitkeep tests/phase4/.gitkeep tests/phase5/.gitkeep
```

---

## 3. Bug Fix Integration with TDD

### 3.1 Pattern: Fix First, Then RED Test

For known bugs like hardcoded paths, the approach is:

1. **GREEN (existing code)**: Run existing code to see current behavior
2. **RED (test for fix)**: Write test that asserts correct behavior
3. **GREEN (implement fix)**: Fix the code
4. **REFACTOR**: Verify fix is clean

### 3.2 Example: Hardcoded Path Bug

**File**: `scripts/debian/bootstrap/ai.sh`

**Current Bug (line 5)**:
```bash
ROOT="$HOME/dotfiles/scripts/debian"
```

**Test to verify fix**:
```bash
@test "bootstrap uses dirname BASH_SOURCE for dynamic path" {
    # Create a temporary installation structure
    local fake_install="/tmp/fake-install"
    mkdir -p "$fake_install/scripts/debian/bootstrap"
    cp "$PROJECT_ROOT/scripts/debian/bootstrap/ai.sh" "$fake_install/scripts/debian/bootstrap/"
    
    # Execute from different directory (simulating installation elsewhere)
    cd "/tmp"
    source "$fake_install/scripts/debian/bootstrap/ai.sh"
    
    # ROOT should be computed, not hardcoded
    [[ "$ROOT" == "$fake_install/scripts/debian" ]]
}
```

### 3.3 Bug Fix Work Units

| Bug | Test File | Fix Approach |
|-----|-----------|--------------|
| BUG-FIX-1: `$HOME/dotfiles` in bootstrap | `phase5/error_missing_binary.bats` | Write test asserting dynamic path, fix script |
| BUG-FIX-2: `$HOME/dotfiles` in router.sh | `phase3/router_integration.bats` | Write test asserting relative sourcing, fix script |
| BUG-FIX-3: hardcoded paths in menu.sh | `phase4/menu_interaction.bats` | Write test asserting SCRIPT_DIR usage, fix script |
| BUG-FIX-4: wrong repo URL in recovery.md | Manual verification test | Add test that checks URL pattern in docs |

---

## 4. Mock Strategy Details

### 4.1 Gemini Mock Implementation

```bash
load_gemini_mock() {
    export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
    
    cat > "$BATS_TEST_TMPDIR/bin/gemini" <<'GEMINI_MOCK'
#!/usr/bin/env bash
# Mock gemini command

# Check for --prompt flag
if [[ "$*" == *"--prompt"* ]]; then
    # Extract prompt
    prompt=$(echo "$*" | sed 's/.*--prompt //')
    
    if [[ "$prompt" == *"QUOTA"* ]]; then
        echo "QUOTA_EXHAUSTED"
        exit 0
    fi
    
    echo "[mock-gemini] processed: ${prompt:0:50}..."
    exit 0
fi

echo "[mock-gemini] no prompt provided"
exit 1
GEMINI_MOCK
    chmod +x "$BATS_TEST_TMPDIR/bin/gemini"
}
```

### 4.2 TMUX Mock Implementation

```bash
load_tmux_mock() {
    export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
    
    cat > "$BATS_TEST_TMPDIR/bin/tmux" <<'TMUX_MOCK'
#!/usr/bin/env bash
# Mock tmux command

case "$1" in
    has-session)
        if [[ " $FAKE_TMUX_SESSIONS " =~ " $2 " ]]; then
            exit 0
        fi
        exit 1
        ;;
    new-session)
        # Silently succeed
        exit 0
        ;;
    send-keys)
        # Silently succeed
        exit 0
        ;;
    attach)
        # Silently succeed
        exit 0
        ;;
    switch-client)
        # Silently succeed
        exit 0
        ;;
    list-sessions)
        echo "$FAKE_TMUX_SESSIONS" | tr ' ' '\n'
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
TMUX_MOCK
    chmod +x "$BATS_TEST_TMPDIR/bin/tmux"
}
```

### 4.3 Engram Mock Implementation

```bash
load_engram_mock() {
    export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
    
    cat > "$BATS_TEST_TMPDIR/bin/engram" <<'ENGRAM_MOCK'
#!/usr/bin/env bash
# Mock engram command

case "$1" in
    context)
        echo "[mock-engram] context: $2"
        exit 0
        ;;
    search)
        echo "[mock-engram] search results for: $2"
        echo "- prior work on $2"
        echo "- context from previous sessions"
        exit 0
        ;;
    save)
        echo "[mock-engram] saved: $2"
        exit 0
        ;;
    *)
        echo "[mock-engram] unknown command: $1"
        exit 1
        ;;
esac
ENGRAM_MOCK
    chmod +x "$BATS_TEST_TMPDIR/bin/engram"
}
```

---

## 5. Test Execution Flow

### 5.1 Local Execution

```bash
# Run all tests
bats --recursive tests/

# Run specific phase
bats tests/phase1/
bats tests/phase2/

# Run single test file
bats tests/phase1/project_detection.bats

# Run test matching pattern
bats --filter "detect_project" tests/
```

### 5.2 Device Execution via SSH

```bash
# Execute all tests on Termux phone
ssh phone-ai -p 8022 "cd ~/dotfiles && bats --recursive tests/"

# Execute specific phase on device
ssh phone-ai -p 8022 "cd ~/dotfiles && bats tests/phase1/"

# Watch test output in real-time
ssh phone-ai -p 8022 "cd ~/dotfiles && bats --pretty tests/phase1/"
```

### 5.3 CI-Safe Test Execution

```bash
# Skip tmux tests when tmux unavailable
if command -v tmux >/dev/null 2>&1; then
    bats tests/phase4/
else
    echo "Skipping tmux-dependent tests (tmux not available)"
fi

# Skip engram tests when engram unavailable
if command -v engram >/dev/null 2>&1; then
    bats tests/phase1/memory_integration.bats
fi
```

### 5.4 Verbose Test Output

```bash
# Show all test output (not just failures)
bats --pretty tests/phase1/

# Show TAP format for CI integration
bats --tap tests/phase1/ > test-results.tap

# Show timing information
bats --show-output-of-passing-tests tests/phase1/
```

---

## 6. Strict TDD Workflow Per Unit

### 6.1 TDD Cycle per Function

```
┌─────────────────────────────────────────────────────────┐
│  RED: Write minimal failing test                        │
│  - Write test for ONE behavior                         │
│  - Run test, confirm it FAILS                          │
│  - Failure must be for expected reason (feature missing)│
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│  GREEN: Write minimal code to pass test                 │
│  - Write only what test needs                          │
│  - No YAGNI, no "improvements"                         │
│  - Run test, confirm it PASSES                         │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│  REFACTOR: Clean up code (only after green)            │
│  - Remove duplication                                  │
│  - Improve names                                        │
│  - Tests must still PASS                               │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
                    Next function
```

### 6.2 Test Naming Convention

```
test_{module}_{function}_{scenario}

Examples:
- test_project_detect_project_finds_git_root
- test_project_detect_project_falls_back_to_pwd
- test_runtime_detect_runtime_mobile_detection
- test_state_save_current_workspace_writes_file
```

### 6.3 Test Structure Template

```bash
#!/usr/bin/env bats

load test_helper

@test "module:function - scenario description" {
    # Given: Setup preconditions
    local test_dir="$BATS_TEST_TMPDIR/test-project"
    mkdir -p "$test_dir/.git"
    
    # And: Set environment variables
    export SOME_VAR="test-value"
    
    # When: Execute the function under test
    source "$PROJECT_ROOT/scripts/ai/core/project.sh"
    result="$(detect_project)"
    
    # Then: Assert expected outcomes
    [[ "$result" == "$test_dir" ]]
}
```

---

## 7. Work Unit Commit Structure

### 7.1 Phase 1 Commits (Core Modules)

Each module's tests are a separate commit following `work-unit-commits` skill:

```bash
# Commit structure for Phase 1
git commit -m "feat(tests): add project.sh detection tests"
git commit -m "feat(tests): add runtime detection tests"
git commit -m "fix(paths): use dirname BASH_SOURCE for bootstrap paths"  # Bug fix work unit
git commit -m "feat(tests): add state management tests"
git commit -m "feat(tests): add memory integration tests"
git commit -m "feat(tests): add hydration context tests"
git commit -m "feat(tests): add sync operations tests"
git commit -m "feat(tests): add provider selector tests"
git commit -m "feat(tests): add agent router tests"
git commit -m "feat(tests): add skill detector tests"
git commit -m "feat(tests): add skill registry tests"
```

### 7.2 Phase 2 Commits (Providers)

```bash
git commit -m "feat(tests): add gemini provider tests"
git commit -m "feat(tests): add claude provider tests"
git commit -m "feat(tests): add opencode provider tests"
git commit -m "feat(tests): add gentle provider tests"
```

### 7.3 Phase 3 Commits (Integration)

```bash
git commit -m "feat(tests): add ai.sh main entry point tests"
git commit -m "feat(tests): add router integration tests"
git commit -m "fix(paths): use relative path for provider sourcing in router.sh"  # Bug fix
```

### 7.4 Phase 4 Commits (Launchers)

```bash
git commit -m "feat(tests): add menu interaction tests"
git commit -m "fix(paths): use SCRIPT_DIR for self-location in menu.sh"  # Bug fix
git commit -m "feat(tests): add utils functions tests"
git commit -m "feat(tests): add workspace launcher tests"
git commit -m "feat(tests): add template build_layout tests"
```

### 7.5 Phase 5 Commits (Error Paths)

```bash
git commit -m "feat(tests): add empty prompt handling tests"
git commit -m "feat(tests): add missing .env handling tests"
git commit -m "feat(tests): add tmux unavailable tests"
git commit -m "feat(tests): add network offline detection tests"
git commit -m "feat(tests): add provider binary missing fallback tests"
git commit -m "fix(docs): correct repo URL in recovery.md"  # Bug fix
```

### 7.6 Commit Message Convention

Based on Conventional Commits:
- `feat(tests):` — New test coverage
- `fix(paths):` — Path-related bug fixes (hardcoded paths)
- `fix(docs):` — Documentation fixes (wrong URLs)
- `refactor(tests):` — Test infrastructure improvements

---

## 8. Test Helper Enhancement Plan

### 8.1 Phase 1 Enhancement: Core Mocks

Add to `test_helper.bash`:

```bash
# bats-file for file assertions
# bats-assert for output assertions
# bats-support for test infrastructure

# Mocks for external binaries
setup_mocks() {
    mkdir -p "$BATS_TEST_TMPDIR/bin"
    export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

teardown_mocks() {
    # Cleanup is automatic via BATS_TEST_TMPDIR
    true
}
```

### 8.2 Phase 2 Enhancement: Provider Mocks

Add `load_gemini_mock()`, `load_opencode_mock()`, etc.:

```bash
load_gemini_mock() { ... }
load_opencode_mock() { ... }
load_claude_mock() { ... }
load_gentle_mock() { ... }
load_engram_mock() { ... }
load_tmux_mock() { ... }
```

### 8.3 Phase 3 Enhancement: Integration Fixtures

Add fixtures for testing `ai.sh` bootstrap:

```bash
create_ai_sh_test_environment() {
    export AI_WORKSPACE="$BATS_TEST_TMPDIR/workspace"
    export STATE_DIR="$BATS_TEST_TMPDIR/state"
    mkdir -p "$AI_WORKSPACE" "$STATE_DIR"
}
```

### 8.4 Phase 4 Enhancement: TMUX Session Fixtures

```bash
create_tmux_session_fixture() {
    local session_name="$1"
    export FAKE_TMUX_SESSIONS="$session_name"
}

cleanup_tmux_fixture() {
    unset FAKE_TMUX_SESSIONS
}
```

### 8.5 Phase 5 Enhancement: Error Condition Fixtures

```bash
simulate_network_offline() {
    # Override ping to always fail
    ping() { return 1; }
}

simulate_binary_missing() {
    local bin_name="$1"
    eval "${bin_name}() { echo '$bin_name: command not found'; return 127; }"
}
```

---

## 9. Dependencies and Installation

### 9.1 Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| `bats` | Test framework | `apt install bats` or `npm install -g bats` |
| `bats-assert` | Assertion library | Clone `bats-core/bats-assert` to `tests/` |
| `bats-file` | File assertions | Clone `bats-core/bats-file` to `tests/` |
| `bats-support` | Test helpers | Clone `bats-core/bats-support` to `tests/` |
| `bats-mock` | Binary mocking | Clone `ztombol/bats-mock` to `tests/` |

### 9.2 Test Libraries Installation

```bash
cd tests/
git clone --depth 1 https://github.com/bats-core/bats-assert.git
git clone --depth 1 https://github.com/bats-core/bats-file.git
git clone --depth 1 https://github.com/bats-core/bats-support.git
git clone --depth 1 https://github.com/ztombol/bats-mock.git
```

### 9.3 bats-load Library for Mock Loading

Create `tests/bats-load.bash` for loading mocks:

```bash
# Load bats libraries
load bats-support/load.bash
load bats-assert/load.bash
load bats-file/load.bash

# Load bats-mock
load bats-mock/lib/mock.bash

# Load test helper
load test_helper.bash
```

---

## 10. Acceptance Criteria for Design

- [ ] `test_helper.bash` provides path resolution, mocks, and fixtures
- [ ] bats-mock integration pattern documented
- [ ] All 5 phase directories with correct file list documented
- [ ] Bug fix integration follows TDD pattern (fix first or test first)
- [ ] Mock strategy covers: curl/gemini, tmux, provider binaries, engram
- [ ] Test execution flow documented for local and SSH device execution
- [ ] Strict TDD cycle documented per unit
- [ ] Work unit commit structure follows `work-unit-commits` skill
- [ ] All spec scenarios have corresponding test approach documented

---

## 11. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hardcoded paths in tests | HIGH | MEDIUM | Use `resolve_script()`, `resolve_core()` helpers from `test_helper.bash` |
| TMUX not available in CI | HIGH | LOW | Skip tmux-dependent tests with `command -v tmux` check |
| Provider API mocking complex | MEDIUM | MEDIUM | Use `bats-mock` stubs for binary-level mocking |
| SSH connection flaky | MEDIUM | LOW | Run tests locally when possible, device tests supplementary |
| Tests pollute tmux state | MEDIUM | MEDIUM | Use unique session names with `$BATS_TEST_TMPDIR`, teardown cleanup |
| Mock pollution between tests | MEDIUM | MEDIUM | Reset all mocks in `teardown()`, use `export -n` to unset functions |
| State file collisions | MEDIUM | MEDIUM | Use `$BATS_TEST_TMPDIR` for all `STATE_DIR`, `SYNC_ROOT` overrides |
| Circular symlinks in test dirs | LOW | LOW | `detect_project` already handles via `while` loop with `/` termination |

---

*Design created: 2026-06-02*
*Author: sdd-design sub-agent*
*Skill Resolution: paths-injected — 2 skills (test-driven-development, work-unit-commits)*