# SDD Tasks: Test-Apply (AI Workspace TDD Coverage)

## Change ID
`Test-Apply`

## Intent
Break the SDD change into concrete, actionable, test-first implementation tasks using strict TDD (Red-Green-Refactor) with bats framework.

---

## Phase 1: Core Module Tests + Bug Fixes (CRITICAL)

### P1-T1: Fix hardcoded paths bug in bootstrap/ai.sh + write test
- [x] **Description**: Fix `scripts/debian/bootstrap/ai.sh` line 5 where `ROOT="$HOME/dotfiles/scripts/debian"` is hardcoded. Use `$(dirname "${BASH_SOURCE[0]}")` instead. Write test to verify dynamic path resolution works when script is executed from different installation locations.
- **Files**: `scripts/debian/bootstrap/ai.sh`, `tests/phase5/error_missing_binary.bats`
- **TDD**: RED: Write test asserting ROOT uses BASH_SOURCE[0] → GREEN: Fix ROOT assignment → REFACTOR: Verify clean fix
- **Verification**: `bats tests/phase5/error_missing_binary.bats`
- **Status**: COMPLETED - ROOT now uses `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`
- **Dependencies**: None
- **Effort**: Small

### P1-T2: Fix hardcoded paths bug in router.sh + write test
- [x] **Description**: Fix `scripts/ai/core/router.sh` lines 7-11 where hardcoded `$HOME/dotfiles` appears in provider sourcing. Use `SCRIPT_DIR` derived from `BASH_SOURCE[0]`. Write test to verify relative path sourcing works.
- **Files**: `scripts/ai/core/router.sh`, `tests/phase3/router_integration.bats`
- **TDD**: RED: Write test asserting BASE_DIR derived from BASH_SOURCE → GREEN: Fix sourcing paths → REFACTOR: Verify clean
- **Verification**: `bats tests/phase3/router_integration.bats`
- **Status**: COMPLETED - Already used SCRIPT_DIR/BASE_DIR pattern (verified by tests)
- **Dependencies**: None
- **Effort**: Small

### P1-T3: Fix hardcoded paths bug in menu.sh + write test
- [x] **Description**: Fix `scripts/ai/menu.sh` where hardcoded paths reference other scripts. Use `SCRIPT_DIR` for self-location. Write test to verify menu correctly invokes sibling scripts using relative paths.
- **Files**: `scripts/ai/menu.sh`, `tests/phase4/menu_interaction.bats`
- **TDD**: RED: Write test asserting SCRIPT_DIR usage → GREEN: Fix hardcoded paths → REFACTOR: Verify clean
- **Verification**: `bats tests/phase4/menu_interaction.bats`
- **Status**: COMPLETED - Already used SCRIPT_DIR pattern (verified by tests)
- **Dependencies**: None
- **Effort**: Small

### P1-T4: Fix recovery.md URL bug + write test
- [x] **Description**: Fix `docs/recovery.md` line 557 where repo URL is `ipproyectosysoluciones/termux-dotfiles` instead of `bladimir/Termux-AI-Astaroth`. Write test to verify correct URL pattern in documentation.
- **Files**: `docs/recovery.md`, `tests/phase1/recovery_url_fix.bats`
- **TDD**: RED: Write test asserting correct repo URL → GREEN: Fix URL → REFACTOR: Verify doc consistency
- **Verification**: `bats tests/phase1/recovery_url_fix.bats`
- **Status**: COMPLETED - URL fixed to `https://github.com/bladimir/Termux-AI-Astaroth.git`
- **Dependencies**: None
- **Effort**: Small

### P1-T5: Write project.sh detection tests
- **Description**: Write tests for `scripts/ai/core/project.sh`: `detect_project` (git/node/docker/rust/python fallback to PWD), `project_name`, `project_type`, `git_branch`. Create test fixtures for each project type.
- **Files**: `scripts/ai/core/project.sh`, `tests/phase1/project_detection.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/project_detection.bats`
- **Dependencies**: P1-T1 (path fix ensures correct script loading)
- **Effort**: Large

### P1-T6: Write runtime.sh detection tests
- **Description**: Write tests for `scripts/ai/core/runtime.sh`: `detect_runtime` (mobile/remote/local), `detect_tmux_mode` (nested/standalone), `detect_network` (online/offline). Mock environment variables and filesystem checks.
- **Files**: `scripts/ai/core/runtime.sh`, `tests/phase1/runtime_detection.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/runtime_detection.bats`
- **Dependencies**: P1-T1
- **Effort**: Medium

### P1-T7: Write state.sh management tests
- **Description**: Write tests for `scripts/ai/core/state.sh`: `save_current_workspace`, `load_current_workspace`, `clear_current_workspace`. Use temporary STATE_DIR for isolation.
- **Files**: `scripts/ai/core/state.sh`, `tests/phase1/state_management.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/state_management.bats`
- **Dependencies**: P1-T1
- **Effort**: Medium

### P1-T8: Write memory.sh integration tests
- **Description**: Write tests for `scripts/ai/core/memory.sh`: `memory_available`, `memory_project_context`, `memory_search`, `memory_save`. Mock `engram` command or skip when unavailable.
- **Files**: `scripts/ai/core/memory.sh`, `tests/phase1/memory_integration.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/memory_integration.bats`
- **Dependencies**: P1-T1
- **Effort**: Medium

### P1-T9: Write hydration.sh context tests
- **Description**: Write tests for `scripts/ai/core/hydration.sh`: `build_context` function. Verify context composition includes memory, project info, and branch.
- **Files**: `scripts/ai/core/hydration.sh`, `tests/phase1/hydration_context.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/hydration_context.bats`
- **Dependencies**: P1-T7, P1-T8
- **Effort**: Medium

### P1-T10: Write sync.sh operations tests
- **Description**: Write tests for `scripts/ai/core/sync.sh`: `sync_project_path`, `mirror_project`, `provider_workspace`, `ensure_sync_root`. Use temporary SYNC_ROOT.
- **Files**: `scripts/ai/core/sync.sh`, `tests/phase1/sync_operations.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/sync_operations.bats`
- **Dependencies**: P1-T1
- **Effort**: Medium

### P1-T11: Write provider_selector.sh routing tests
- **Description**: Write tests for `scripts/ai/core/provider_selector.sh`: `select_provider` covering all intent routing cases (research→gemini, devops→opencode, coding→opencode, mistral→mistral, default→opencode). Mock `provider_available`.
- **Files**: `scripts/ai/core/provider_selector.sh`, `tests/phase1/provider_selector.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/provider_selector.bats`
- **Dependencies**: P1-T1, P1-T2
- **Effort**: Medium

### P1-T12: Write agent_router.sh tests
- **Description**: Write tests for `scripts/ai/core/agent_router.sh`: `route_agent_provider` covering rag-agent→gemini, kubernetes-agent→opencode, mern-agent→claude, terminal-agent→opencode, editor-agent→claude, mistral→mistral, unknown→opencode.
- **Files**: `scripts/ai/core/agent_router.sh`, `tests/phase1/agent_router.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/agent_router.bats`
- **Dependencies**: P1-T2
- **Effort**: Medium

### P1-T13: Write skill_detector.sh tests
- **Description**: Write tests for `scripts/ai/core/skill_detector.sh`: `detect_skill` with case-insensitive keyword matching (rag-research, k8s-devops, mern-engineer, terminal-automation, editor-engineering, general fallback).
- **Files**: `scripts/ai/core/skill_detector.sh`, `tests/phase1/skill_detector.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/skill_detector.bats`
- **Dependencies**: None
- **Effort**: Medium

### P1-T14: Write skill_registry.sh tests
- **Description**: Write tests for `scripts/ai/core/skill_registry.sh`: `load_skill_registry`, `skill_exists`, `list_skills`. Create temporary registry fixtures.
- **Files**: `scripts/ai/core/skill_registry.sh`, `tests/phase1/skill_registry.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase1/skill_registry.bats`
- **Dependencies**: None
- **Effort**: Medium

---

## Phase 2: Provider Tests (HIGH)

### P2-T15: Write gemini.sh provider tests
- **Description**: Write tests for `scripts/ai/providers/gemini.sh`: `run_gemini` with successful execution, QUOTA_EXHAUSTED fallback to opencode, generic failure fallback to gentle, missing API key handling. Mock `curl` for API interception.
- **Files**: `scripts/ai/providers/gemini.sh`, `tests/phase2/gemini_provider.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase2/gemini_provider.bats`
- **Dependencies**: P1-T1, P1-T2
- **Effort**: Large

### P2-T16: Write claude.sh provider tests
- **Description**: Write tests for `scripts/ai/providers/claude.sh`: `run_claude` with proper env vars (CLAUDE_PROJECT, CLAUDE_AGENT, CLAUDE_SKILL, CLAUDE_WORKSPACE), missing binary handling.
- **Files**: `scripts/ai/providers/claude.sh`, `tests/phase2/claude_provider.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase2/claude_provider.bats`
- **Dependencies**: P1-T2
- **Effort**: Medium

### P2-T17: Write opencode.sh provider tests
- **Description**: Write tests for `scripts/ai/providers/opencode.sh`: `run_opencode` with successful execution, missing binary returns error.
- **Files**: `scripts/ai/providers/opencode.sh`, `tests/phase2/opencode_provider.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase2/opencode_provider.bats`
- **Dependencies**: P1-T2
- **Effort**: Medium

### P2-T18: Write gentle.sh provider tests
- **Description**: Write tests for `scripts/ai/providers/gentle.sh`: `gentle_sync`, `gentle_upgrade`, `gentle_refresh_skills` with available/unavailable binary scenarios.
- **Files**: `scripts/ai/providers/gentle.sh`, `tests/phase2/gentle_provider.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase2/gentle_provider.bats`
- **Dependencies**: P1-T2
- **Effort**: Medium

---

## Phase 3: Integration Tests (HIGH)

### P3-T19: Write ai.sh main entry point tests
- **Description**: Write tests for `scripts/ai/ai.sh` (292 lines): bootstrap loading all 30+ modules, project detection integration, runtime detection integration, intent routing integration, agent resolution integration, doctor command, resume command.
- **Files**: `scripts/ai/ai.sh`, `tests/phase3/main_entry_point.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement integration → REFACTOR: Clean up
- **Verification**: `bats tests/phase3/main_entry_point.bats`
- **Dependencies**: P1-T5, P1-T6, P1-T11, P1-T12, P1-T13
- **Effort**: Large

### P3-T20: Write router.sh integration tests
- **Description**: Write tests for `scripts/ai/core/router.sh`: `run_provider` dispatch to all providers (opencode, gemini, claude, mistral, gentle), unknown provider error. Includes BUG-FIX-2 verification for relative path sourcing.
- **Files**: `scripts/ai/core/router.sh`, `tests/phase3/router_integration.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase3/router_integration.bats`
- **Dependencies**: P1-T2, P2-T15, P2-T16, P2-T17, P2-T18
- **Effort**: Large

---

## Phase 4: Launcher & Template Tests (MEDIUM)

### P4-T21: Write menu.sh interaction tests
- **Description**: Write tests for `scripts/ai/menu.sh`: menu choices (NeoVim→nvim.sh, OpenCode→opencode.sh, Gentle AI→gentle.sh, Exit→exit 0). Includes BUG-FIX-3 verification for SCRIPT_DIR usage. Mock `gum`.
- **Files**: `scripts/ai/menu.sh`, `tests/phase4/menu_interaction.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement menu → REFACTOR: Clean up
- **Verification**: `bats tests/phase4/menu_interaction.bats`
- **Dependencies**: P1-T3
- **Effort**: Medium

### P4-T22: Write utils.sh function tests
- **Description**: Write tests for `scripts/ai/utils.sh`: `session_exists`, `attach_or_switch`, `create_session`. Mock tmux commands.
- **Files**: `scripts/ai/utils.sh`, `tests/phase4/utils_functions.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement functions → REFACTOR: Clean up
- **Verification**: `bats tests/phase4/utils_functions.bats`
- **Dependencies**: None (utils may be standalone)
- **Effort**: Medium

### P4-T23: Write workspace.sh launcher tests
- **Description**: Write tests for `scripts/ai/core/workspace.sh`: template selection auto-detection based on runtime when no argument given (mobile→mobile, node→node, default→default).
- **Files**: `scripts/ai/core/workspace.sh`, `tests/phase4/workspace_launcher.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement function → REFACTOR: Clean up
- **Verification**: `bats tests/phase4/workspace_launcher.bats`
- **Dependencies**: P1-T6
- **Effort**: Medium

### P4-T24: Write template build_layout tests
- **Description**: Write tests for `scripts/ai/templates/*.sh`: build_layout functions for all 4 templates (default, mobile, node, remote). Verify correct tmux windows and commands. Mock tmux.
- **Files**: `scripts/ai/templates/default.sh`, `mobile.sh`, `node.sh`, `remote.sh`, `tests/phase4/templates.bats`
- **TDD**: RED: Write failing tests → GREEN: Implement templates → REFACTOR: Clean up
- **Verification**: `bats tests/phase4/templates.bats`
- **Dependencies**: P4-T22
- **Effort**: Medium

---

## Phase 5: Error Path Tests (MEDIUM)

### P5-T25: Write empty prompt error tests
- **Description**: Write tests for `ai.sh` with no arguments/empty prompt handling. Verify graceful handling without crashes.
- **Files**: `tests/phase5/error_empty_prompt.bats`
- **TDD**: RED: Write test for graceful handling → GREEN: Ensure code handles empty → REFACTOR: Clean up
- **Verification**: `bats tests/phase5/error_empty_prompt.bats`
- **Dependencies**: P3-T19
- **Effort**: Small

### P5-T26: Write missing .env error tests
- **Description**: Write tests for provider scripts sourcing missing .env file. Verify no sourcing errors, provider variables have defaults.
- **Files**: `tests/phase5/error_missing_env.bats`
- **TDD**: RED: Write test for missing .env → GREEN: Ensure graceful handling → REFACTOR: Clean up
- **Verification**: `bats tests/phase5/error_missing_env.bats`
- **Dependencies**: P2-T15, P2-T16, P2-T17, P2-T18
- **Effort**: Small

### P5-T27: Write no tmux error tests
- **Description**: Write tests for tmux unavailable scenarios: `session_exists` returns 1, `create_session` handles gracefully, `ai.sh` exits with clear error.
- **Files**: `tests/phase5/error_no_tmux.bats`
- **TDD**: RED: Write test for tmux missing → GREEN: Ensure graceful handling → REFACTOR: Clean up
- **Verification**: `bats tests/phase5/error_no_tmux.bats`
- **Dependencies**: P4-T22
- **Effort**: Small

### P5-T28: Write network offline error tests
- **Description**: Write tests for `detect_network` returning "offline" when network unavailable. Mock `ping` to fail.
- **Files**: `tests/phase5/error_network_offline.bats`
- **TDD**: RED: Write test for offline detection → GREEN: Ensure offline returned → REFACTOR: Clean up
- **Verification**: `bats tests/phase5/error_network_offline.bats`
- **Dependencies**: P1-T6
- **Effort**: Small

### P5-T29: Write missing binary error tests
- **Description**: Write tests for provider fallback chains when primary provider unavailable. Verify fallback to secondary providers works. Includes BUG-FIX-1 verification.
- **Files**: `tests/phase5/error_missing_binary.bats`
- **TDD**: RED: Write test for fallback chain → GREEN: Ensure fallback works → REFACTOR: Clean up
- **Verification**: `bats tests/phase5/error_missing_binary.bats`
- **Dependencies**: P2-T15, P2-T17, P2-T18
- **Effort**: Small

---

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~3,200 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Decision needed before apply | Yes |

### Work Units (for chained PRs)

- **PR 1**: Bug fixes (P1-T1, P1-T2, P1-T3, P1-T4) — fix hardcoded paths in bootstrap, router, menu, and recovery URL — ~80 lines
- **PR 2**: Phase 1 core module tests part 1 (P1-T5, P1-T6, P1-T7, P1-T8) — project, runtime, state, memory tests — ~600 lines
- **PR 3**: Phase 1 core module tests part 2 (P1-T9, P1-T10, P1-T11, P1-T12) — hydration, sync, provider_selector, agent_router tests — ~600 lines
- **PR 4**: Phase 1 core module tests part 3 (P1-T13, P1-T14) — skill_detector, skill_registry tests — ~300 lines
- **PR 5**: Phase 2 provider tests (P2-T15, P2-T16, P2-T17, P2-T18) — gemini, claude, opencode, gentle provider tests — ~700 lines
- **PR 6**: Phase 3 integration tests (P3-T19, P3-T20) — ai.sh and router integration tests — ~500 lines
- **PR 7**: Phase 4 launcher & template tests (P4-T21, P4-T22, P4-T23, P4-T24) — menu, utils, workspace, templates — ~400 lines
- **PR 8**: Phase 5 error path tests (P5-T25, P5-T26, P5-T27, P5-T28, P5-T29) — error handling tests — ~250 lines

---

## Dependencies Summary

```
Phase 1 (CRITICAL)
├── P1-T1: bootstrap path fix     ← No deps
├── P1-T2: router path fix        ← No deps
├── P1-T3: menu path fix          ← No deps
├── P1-T4: recovery URL fix       ← No deps
├── P1-T5: project tests         ← P1-T1
├── P1-T6: runtime tests         ← P1-T1
├── P1-T7: state tests           ← P1-T1
├── P1-T8: memory tests          ← P1-T1
├── P1-T9: hydration tests        ← P1-T7, P1-T8
├── P1-T10: sync tests           ← P1-T1
├── P1-T11: provider_selector    ← P1-T1, P1-T2
├── P1-T12: agent_router         ← P1-T2
├── P1-T13: skill_detector       ← No deps
└── P1-T14: skill_registry       ← No deps

Phase 2 (HIGH)
├── P2-T15: gemini tests         ← P1-T1, P1-T2
├── P2-T16: claude tests         ← P1-T2
├── P2-T17: opencode tests       ← P1-T2
└── P2-T18: gentle tests         ← P1-T2

Phase 3 (HIGH)
├── P3-T19: ai.sh integration    ← P1-T5, P1-T6, P1-T11, P1-T12, P1-T13
└── P3-T20: router integration   ← P1-T2, P2-T15, P2-T16, P2-T17, P2-T18

Phase 4 (MEDIUM)
├── P4-T21: menu interaction     ← P1-T3
├── P4-T22: utils functions      ← No deps
├── P4-T23: workspace launcher   ← P1-T6
└── P4-T24: template build_layout ← P4-T22

Phase 5 (MEDIUM)
├── P5-T25: empty prompt         ← P3-T19
├── P5-T26: missing .env         ← P2-T15, P2-T16, P2-T17, P2-T18
├── P5-T27: no tmux              ← P4-T22
├── P5-T28: network offline      ← P1-T6
└── P5-T29: missing binary       ← P2-T15, P2-T17, P2-T18
```

---

## Task Execution Notes

1. **Strict TDD**: Each task follows Red-Green-Refactor. Write failing test first, confirm it fails for expected reason, then write minimal code to pass.

2. **Test helper enhancement**: `tests/test_helper.bash` must be extended in P1-T5's early stages with:
   - Path resolution helpers (`resolve_script`, `resolve_core`, `resolve_provider`)
   - Mock functions (`mock_gemini`, `mock_tmux`, `mock_engram`)
   - Fixtures (`create_test_project`, `cleanup_test_project`)

3. **Existing tests**: Some test files already exist (`phase1/recovery_url_fix.bats`, `phase2/provider_doc_*.bats`, `phase3/mistral_*.bats`, `phase4/tmux_var_expansion.bats`). Review and enhance rather than replace.

4. **bats libraries**: Install required libraries if not present:
   ```bash
   cd tests/
   git clone --depth 1 https://github.com/bats-core/bats-assert.git
   git clone --depth 1 https://github.com/bats-core/bats-file.git
   git clone --depth 1 https://github.com/bats-core/bats-support.git
   ```

5. **CI-safety**: Use `command -v tmux` checks to skip tmux-dependent tests when unavailable. Use `FAKE_*` environment variables to mock external binaries.

---

*Tasks created: 2026-06-02*
*Author: sdd-tasks sub-agent*
*Skill Resolution: paths-injected — 3 skills (test-driven-development, work-unit-commits, chained-pr)*