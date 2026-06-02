# Exploration: Test-Apply (AI Workspace TDD Coverage Audit)

## Topic
Exhaustive audit of the AI Workspace framework to identify all gaps in TDD test coverage, document bugs found, and create a comprehensive testing roadmap for complete TDD coverage.

---

## Executive Summary

The AI Workspace framework (`scripts/ai/`) has **24 existing tests** (23 passing, 1 failing) across phases 1-4, but test coverage is severely incomplete. The framework consists of **30+ core modules**, **5 providers**, **4 templates**, and **multiple launcher scripts** — yet there are massive gaps in testing. Critical bugs were found including hardcoded paths, unhandled error paths, and untested edge cases.

**Current test state**: 23 passing, 1 failing (`recovery_url_fix.bats`), 24 total tests across 4 phases.

---

## Framework Structure Analysis

### Scripts Directory Tree

```
scripts/ai/
├── ai.sh                    # MAIN ENTRY POINT (292 lines) — UNTESTED
├── menu.sh                  # Gum-powered launcher menu — UNTESTED
├── popup.sh                 # Tmux popup launcher — UNTESTED
├── workspace.sh             # Full workspace launcher (65 lines) — UNTESTED
├── sessions.sh              # Session switcher — UNTESTED
├── utils.sh                 # Session helpers (29 lines) — UNTESTED
├── ui.sh                    # Gum style helpers (30 lines) — UNTESTED
├── nvim.sh                  # Neovim launcher — UNTESTED
├── opencode.sh              # OpenCode launcher — UNTESTED
├── gentle.sh                # Gentle AI launcher — UNTESTED
├── engram.sh                # Engram launcher — UNTESTED
├── gentl.sh                 # Gentle control plane — UNTESTED
├── core/                    # 30 CORE MODULES — MOSTLY UNTESTED
│   ├── registry.sh          # Provider registry — UNTESTED
│   ├── routing.sh           # Intent detection — UNTESTED
│   ├── provider_selector.sh # Intent-based routing (85 lines) — PARTIALLY TESTED
│   ├── intelligence.sh      # Session resume (48 lines) — UNTESTED
│   ├── metadata.sh          # Workspace metadata — UNTESTED
│   ├── state.sh             # State management (54 lines) — UNTESTED
│   ├── hooks.sh             # Startup hooks — UNTESTED
│   ├── memory.sh            # Engram integration (79 lines) — UNTESTED
│   ├── hydration.sh         # Context building (65 lines) — UNTESTED
│   ├── runtime.sh           # Runtime detection (49 lines) — UNTESTED
│   ├── skill_registry.sh    # Skill registry (34 lines) — UNTESTED
│   ├── skill_detector.sh    # Skill detection from prompt (60 lines) — UNTESTED
│   ├── capability_router.sh  # Capability routing (58 lines) — UNTESTED
│   ├── agent_registry.sh    # Agent resolution (58 lines) — UNTESTED
│   ├── agent_router.sh      # Agent-to-provider routing (67 lines) — UNTESTED
│   ├── agent_context.sh     # Agent system prompts (77 lines) — UNTESTED
│   ├── subagent_registry.sh # Subagent resolution (45 lines) — UNTESTED
│   ├── subagent_runtime.sh  # Subagent spawning (28 lines) — UNTESTED
│   ├── orchestration.sh      # Multi-agent orchestration (30 lines) — UNTESTED
│   ├── runtime_session.sh   # Runtime session mgmt (29 lines) — UNTESTED
│   ├── paths.sh             # Path conversion (59 lines) — UNTESTED
│   ├── sync.sh              # Project sync (61 lines) — UNTESTED
│   ├── policies.sh           # Policy detection (42 lines) — UNTESTED
│   ├── project.sh           # Project detection (78 lines) — UNTESTED
│   ├── session.sh           # Session management (89 lines) — UNTESTED
│   ├── workspace.sh         # Workspace management (81 lines) — UNTESTED
│   ├── layout.sh            # Layout selection/apply (75 lines) — UNTESTED
│   ├── doctor.sh             # Runtime diagnostics (51 lines) — UNTESTED
│   ├── context.sh           # Context detection (50 lines) — UNTESTED
│   └── executor.sh          # Provider executor (30 lines) — UNTESTED
├── providers/               # 5 PROVIDERS — PARTIALLY TESTED
│   ├── mistral.sh          # Mistral AI (64 lines) — PARTIALLY TESTED (syntax, env var, executable, sourcing)
│   ├── gemini.sh           # Gemini with fallback (71 lines) — UNTESTED
│   ├── claude.sh           # Claude wrapper (15 lines) — UNTESTED
│   ├── opencode.sh         # OpenCode wrapper (21 lines) — UNTESTED
│   └── gentle.sh           # Gentle control plane (36 lines) — UNTESTED
├── runtime/
│   ├── ai-runtime.sh       # Runtime executor (89 lines) — PARTIALLY TESTED (tmux var expansion)
│   └── runtime.env         # Runtime environment config — UNTESTED
└── templates/               # 4 LAYOUT TEMPLATES — UNTESTED
    ├── default.sh          # 4-window layout (36 lines)
    ├── mobile.sh          # Mobile-optimized (56 lines)
    ├── node.sh            # Node.js project (40 lines)
    └── remote.sh          # Remote session (20 lines)
```

---

## Current Test Coverage Audit

### Phase 1 Tests (6 tests, 5 passing, 1 failing)

| Test File | Tests | Purpose | Status |
|-----------|-------|---------|--------|
| `installation_ai_tools.bats` | 1 | Verify installation.md references ai.sh | PASS |
| `recovery_doctor_ref.bats` | 1 | Verify recovery.md references doctor.sh | PASS |
| `recovery_phantom_paths.bats` | 2 | Verify scripts in recovery.md exist | PASS |
| `recovery_tpm_docs.bats` | 2 | Verify TPM git clone in recovery.md | PASS |
| `recovery_url_fix.bats` | 1 | Verify old repo URL removed | **FAIL** |

**Issue Found**: `recovery_url_fix.bats` fails because `recovery.md` still contains `ipproyectosysoluciones/termux-dotfiles` at line 557. This is a real bug — the test correctly caught it.

### Phase 2 Tests (6 tests, all passing)

| Test File | Tests | Purpose | Status |
|-----------|-------|---------|--------|
| `provider_doc_exists.bats` | 1 | provider-architecture.md exists | PASS |
| `provider_doc_sections.bats` | 5 | Required sections in doc | PASS |

### Phase 3 Tests (8 tests, all passing)

| Test File | Tests | Purpose | Status |
|-----------|-------|---------|--------|
| `bootstrap_mistral.bats` | 1 | ai.sh contains mistral | PASS |
| `mistral_env_var.bats` | 1 | mistral.sh references MISTRAL_API_KEY | PASS |
| `mistral_executable.bats` | 1 | mistral.sh is executable | PASS |
| `mistral_loads.bats` | 1 | mistral.sh sources without errors | PASS |
| `mistral_syntax.bats` | 1 | mistral.sh valid bash syntax | PASS |
| `provider_selector_mistral.bats` | 1 | provider_selector.sh contains mistral | PASS |

### Phase 4 Tests (4 tests, all passing)

| Test File | Tests | Purpose | Status |
|-----------|-------|---------|--------|
| `tmux_var_expansion.bats` | 4 | Verify \$VAR → $VAR fix in ai.sh and ai-runtime.sh | PASS |

---

## Critical Gaps in Test Coverage

### GAP 1: Main Entry Point `ai.sh` Completely Untested

**File**: `scripts/ai/ai.sh` (292 lines)

**No tests for**:
- Bootstrap loading of all 30+ core modules
- Project detection (`detect_project`, `project_name`, `project_type`, `git_branch`)
- Runtime detection (`detect_runtime`, `detect_network`, `detect_tmux_mode`, `detect_policy`)
- Intent routing (`route_capability`)
- Agent resolution (`resolve_agent`)
- Provider routing (`route_agent_provider`)
- Memory integration (`memory_save`, `memory_project_context`)
- Context hydration (`build_context`)
- Project mirroring (`mirror_project`)
- Runtime session management (`runtime_session_name`, `ensure_runtime_session`)
- TMUX execution paths (nested/standalone, orchestration mode)
- Error handling paths

**Tests needed**:
- `ai.sh` sources all core modules without errors
- Project detection works for node, rust, python, docker, generic projects
- Runtime detection returns correct mode (mobile/remote/local)
- Intent routing correctly classifies prompts
- Agent resolution returns correct agent for skill
- Provider routing returns correct provider for agent

### GAP 2: Core Module Tests Missing

**Critical modules with zero tests**:

1. **`core/project.sh`** (78 lines) — project detection
2. **`core/runtime.sh`** (49 lines) — runtime/mode detection
3. **`core/state.sh`** (54 lines) — workspace state
4. **`core/memory.sh`** (79 lines) — engram integration
5. **`core/hydration.sh`** (65 lines) — context building
6. **`core/sync.sh`** (61 lines) — project mirroring
7. **`core/provider_selector.sh`** (85 lines) — routing logic
8. **`core/agent_router.sh`** (67 lines) — provider routing
9. **`core/skill_detector.sh`** (60 lines) — skill from prompt
10. **`core/skill_registry.sh`** (34 lines) — skill registry

### GAP 3: Provider Tests Incomplete

**Current state**: Only `mistral.sh` has tests (syntax, env var, executable, sourcing).

**Missing tests**:

1. **`providers/gemini.sh`** (71 lines):
   - Tests for `run_gemini` function
   - Tests for QUOTA_EXHAUSTED fallback to opencode
   - Tests for generic failure fallback to gentle
   - Mock API responses for testing
   - Exit code verification

2. **`providers/claude.sh`** (15 lines):
   - Tests that it sources correct env vars
   - Tests that it calls `claude` with correct args
   - Tests for missing claude binary handling

3. **`providers/opencode.sh`** (21 lines):
   - Tests `run_opencode` function
   - Tests for missing binary handling
   - Tests for successful execution

4. **`providers/gentle.sh`** (36 lines):
   - Tests for `gentle_sync`, `gentle_upgrade`, `gentle_refresh_skills`
   - Tests for missing gentle-ai binary handling

### GAP 4: Template Tests Missing

**Files**: `templates/default.sh`, `templates/mobile.sh`, `templates/node.sh`, `templates/remote.sh`

**No tests for**:
- `build_layout` function exists and is callable
- Layout creates correct tmux windows
- Session name is passed correctly
- Error handling when tmux not available

### GAP 5: Launcher Script Tests Missing

**Files**: `menu.sh`, `popup.sh`, `workspace.sh`, `sessions.sh`, `nvim.sh`, `opencode.sh`, `gentle.sh`, `engram.sh`

**No tests for**:
- Menu choices trigger correct scripts
- Utils functions work (session_exists, attach_or_switch, create_session)
- Error handling when tmux not running

### GAP 6: Edge Cases Not Tested

**Missing edge case tests**:

1. **Empty prompt handling** — `ai.sh` line 65: `PROMPT="${*:-}"` — what happens with empty args?
2. **Missing `.env` file** — providers source `.env` but don't error if missing
3. **Missing `$HOME/dotfiles`** — hardcoded path assumption throughout
4. **TMUX not available** — all tmux commands will fail without error handling
5. **Provider binary not found** — fallback chains not tested end-to-end
6. **Network offline** — `detect_network` uses `ping` but no test for offline mode
7. **Malformed project directories** — `detect_project` walks up tree but edge cases not tested
8. **Concurrent session creation** — race conditions in `ensure_runtime_session`
9. **Provider workspace path resolution** — `provider_workspace` and `to_debian_path`/`to_termux_path` untested
10. **Skill registry missing** — `skill_exists` will fail if registry file missing

---

## Bugs Found During Exploration

### BUG 1: Hardcoded `$HOME/dotfiles` in `scripts/debian/bootstrap/ai.sh`

**File**: `scripts/debian/bootstrap/ai.sh`, line 5
```bash
ROOT="$HOME/dotfiles/scripts/debian"
```

**Problem**: The script assumes dotfiles are at `$HOME/dotfiles`, but the actual clone is to `$HOME/Termux-AI-Astaroth`.

**Impact**: Running `bash ~/Termux-AI-Astaroth/scripts/debian/bootstrap/ai.sh` will fail because `$HOME/dotfiles/scripts/debian` doesn't exist.

**Test needed**: Verify that bootstrap scripts use correct paths derived from `$(dirname "${BASH_SOURCE[0]}")`.

### BUG 2: `recovery.md` Contains Old Repo URL

**File**: `docs/recovery.md`, line 557
```bash
git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git
```

**Problem**: URL is wrong — should be `https://github.com/bladimir/Termux-AI-Astaroth.git`.

**Test failing**: `recovery_url_fix.bats` correctly catches this, but the bug remains in the doc.

### BUG 3: `router.sh` Sources Hardcoded `$HOME/dotfiles` Paths

**File**: `scripts/ai/core/router.sh`, lines 7-11
```bash
source "$HOME/dotfiles/scripts/ai/providers/claude.sh"
source "$HOME/dotfiles/scripts/ai/providers/gemini.sh"
source "$HOME/dotfiles/scripts/ai/providers/opencode.sh"
source "$HOME/dotfiles/scripts/ai/providers/gentle.sh"
source "$HOME/dotfiles/scripts/ai/providers/mistral.sh"
```

**Problem**: Uses `$HOME/dotfiles` instead of `$(dirname "${BASH_SOURCE[0]}")/../..` pattern.

**Impact**: Works only if dotfiles at `$HOME/dotfiles`. Fails if installed elsewhere.

### BUG 4: `ai-runtime.sh` Sources Hardcoded Path

**File**: `scripts/ai/runtime/ai-runtime.sh`, line 18
```bash
source "$BASE_DIR/runtime/runtime.env"
```

**Good**: Uses `BASE_DIR` which is computed from `SCRIPT_DIR`. But `SCRIPT_DIR` itself uses hardcoded pattern that should be verified.

### BUG 5: Menu Hardcodes `~/dotfiles/scripts/ai/...` Paths

**File**: `scripts/ai/menu.sh`

**Problem**: References hardcoded paths instead of using `SCRIPT_DIR` for self-location.

**Impact**: Only works if installed at `~/dotfiles`.

### BUG 6: `gentle.sh` Doesn't Match Menu Reference

**File**: `scripts/ai/gentle.sh` vs `scripts/ai/menu.sh`

**Problem**: `menu.sh` line 29 calls `gentle.sh` (lowercase), but actual file is `gentle.sh`. This is just a case sensitivity issue on case-insensitive filesystems but could cause issues.

**Note**: File exists as `gentle.sh` in listing but `gentle.sh` content shows `SESSION="gentle"` and references to `gentle-ai`.

---

## Test Infrastructure Assessment

### Test Helper

**File**: `tests/test_helper.bash` (7 lines)

```bash
setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
}
```

**Assessment**: Minimal helper. Could benefit from:
- Mock functions for provider binaries
- Fixtures for creating temporary test projects
- SSH connection helper for device testing

### Test Runner

**Command**: `bats --recursive tests/`

**Current**: All tests run with `bats --recursive tests/`. No separate test runner script, no Makefile.

### CI Configuration

**Status**: No `.github/workflows/` found. No CI configured.

---

## Recommended TDD Test Plan

### Phase 1: Core Module Tests

**Priority: CRITICAL** — These are the foundation

| Test File | Scripts Tested | Tests Needed |
|-----------|---------------|--------------|
| `phase1/project_detection.bats` | `core/project.sh` | detect_project, project_name, project_type, git_branch |
| `phase1/runtime_detection.bats` | `core/runtime.sh` | detect_runtime (mobile/remote/local), detect_network (online/offline), detect_tmux_mode (nested/standalone) |
| `phase1/state_management.bats` | `core/state.sh` | save_current_workspace, load_current_workspace, clear_current_workspace |
| `phase1/provider_selector.bats` | `core/provider_selector.sh` | All intent cases (research, architecture, devops, coding, mistral, default) |

### Phase 2: Provider Tests

**Priority: HIGH**

| Test File | Scripts Tested | Tests Needed |
|-----------|---------------|--------------|
| `phase2/gemini_provider.bats` | `providers/gemini.sh` | run_gemini, QUOTA_EXHAUSTED fallback, generic failure fallback |
| `phase2/claude_provider.bats` | `providers/claude.sh` | run_claude, env vars, missing binary |
| `phase2/opencode_provider.bats` | `providers/opencode.sh` | run_opencode, missing binary |
| `phase2/gentle_provider.bats` | `providers/gentle.sh` | gentle_sync, gentle_upgrade, gentle_refresh_skills |

### Phase 3: Integration Tests

**Priority: HIGH**

| Test File | Integration Point | Tests Needed |
|-----------|------------------|--------------|
| `phase3/router_integration.bats` | `core/router.sh` | All provider routing cases |
| `phase3/memory_integration.bats` | `core/memory.sh` | memory_save, memory_search, memory_project_context |
| `phase3/hydration_integration.bats` | `core/hydration.sh` | build_context with real data |
| `phase3/sync_integration.bats` | `core/sync.sh` | mirror_project, sync_project_path |

### Phase 4: Launcher Tests

**Priority: MEDIUM**

| Test File | Script Tested | Tests Needed |
|-----------|--------------|--------------|
| `phase4/menu_interaction.bats` | `menu.sh` | Menu choices, script invocation |
| `phase4/utils_functions.bats` | `utils.sh` | session_exists, attach_or_switch, create_session |
| `phase4/workspace_launcher.bats` | `workspace.sh` | Template selection, layout application |

### Phase 5: Error Path Tests

**Priority: MEDIUM**

| Test File | Error Scenario | Tests Needed |
|-----------|---------------|--------------|
| `phase5/empty_prompt.bats` | `ai.sh` with no args | Handle empty prompt gracefully |
| `phase5/missing_env.bats` | Provider with no .env | Handle missing MISTRAL_API_KEY |
| `phase5/no_tmux.bats` | No tmux installed | Graceful failure |
| `phase5/network_offline.bats` | Offline mode | detect_network returns offline |
| `phase5/missing_binary.bats` | Provider binary missing | Fallback chain works |

---

## Test Execution Plan for SSH Device Testing

### Prerequisites

1. SSH connection to `phone-ai` on port 8022
2. Dotfiles at `~/dotfiles` (or adjust paths)
3. bats installed on device

### Manual Test Verification Commands

```bash
# Connect to device
ssh phone-ai -p 8022

# Run all tests
cd ~/dotfiles && bats --recursive tests/

# Run specific phase
cd ~/dotfiles && bats tests/phase1/
cd ~/dotfiles && bats tests/phase2/
cd ~/dotfiles && bats tests/phase3/
cd ~/dotfiles && bats tests/phase4/

# Run single test file
cd ~/dotfiles && bats tests/phase4/tmux_var_expansion.bats
```

### Testing Workflow for TDD

1. **RED**: Write failing test on device via SSH
2. **GREEN**: Implement minimal fix
3. **REFACTOR**: Clean up
4. **Verify**: Run tests via SSH to confirm

---

## Risks Identified

1. **Risk: Hardcoded paths break portability** — Multiple scripts assume `$HOME/dotfiles`. Any testing must account for actual install location.

2. **Risk: TMUX dependency not testable in CI** — Tests requiring tmux will fail in CI environment without tmux installed.

3. **Risk: Provider API mocking** — Testing `gemini.sh` and `mistral.sh` requires mocking API responses or having valid API keys.

4. **Risk: SSH connection flaky** — Device connectivity may be unreliable for test execution.

5. **Risk: Test environment pollution** — Tests that create tmux sessions may interfere with existing sessions.

---

## Issues to Create

Based on exploration, the following issues should be created:

### Issue 1: Fix hardcoded `$HOME/dotfiles` paths
**Priority**: HIGH
**Files**: `scripts/debian/bootstrap/ai.sh`, `scripts/ai/core/router.sh`, `scripts/ai/menu.sh`
**Action**: Use `$(dirname "${BASH_SOURCE[0]}")` pattern consistently

### Issue 2: Fix recovery.md repo URL
**Priority**: HIGH
**Files**: `docs/recovery.md` line 557
**Action**: Change `ipproyectosysoluciones/termux-dotfiles` to `bladimir/Termux-AI-Astaroth`

### Issue 3: Add comprehensive core module tests
**Priority**: HIGH
**Files**: All of `scripts/ai/core/` — need tests for project.sh, runtime.sh, state.sh, etc.

### Issue 4: Add provider integration tests
**Priority**: MEDIUM
**Files**: `providers/*.sh` — need full test coverage for fallback chains

### Issue 5: Add error path tests
**Priority**: MEDIUM
**Files**: Various — test empty prompts, missing binaries, offline mode

---

## Summary

The AI Workspace framework has extensive code (30+ core modules, 5 providers, 4 templates) but minimal test coverage (24 tests, mostly basic syntax and doc checks). The testing strategy needs a major overhaul to achieve TDD compliance. Critical bugs include hardcoded paths, a failing doc test, and missing integration tests for the entire provider routing system.

**Next step**: Propose a comprehensive test creation plan (SDD-propose) to address these gaps systematically.

---

## Artifacts

- **Engram**: `sdd/Test-Apply/explore`
- **Filesystem**: `openspec/changes/Test-Apply/exploration.md`