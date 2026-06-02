# SDD Proposal: Test-Apply (AI Workspace TDD Coverage)

## Change ID
`Test-Apply`

## Intent

Create comprehensive TDD tests for the entire AI Workspace framework (`scripts/ai/`), fixing bugs discovered during exploration and establishing a systematic testing practice that catches regressions before they reach production.

**Problem being solved**: The AI Workspace framework has 30+ core modules, 5 providers, and multiple launcher scripts — yet test coverage is severely incomplete. Critical bugs (hardcoded paths, failing docs) exist undetected. This proposal establishes a phased TDD approach that:
1. Writes failing tests first (strict TDD)
2. Fixes bugs found during exploration
3. Builds test coverage systematically by risk/impact

---

## Scope

### In Scope

**Core Modules (Phase 1 — CRITICAL)**
- `scripts/ai/core/project.sh` — detect_project, project_name, project_type, git_branch
- `scripts/ai/core/runtime.sh` — detect_runtime (mobile/remote/local), detect_network, detect_tmux_mode
- `scripts/ai/core/state.sh` — save/load/clear workspace state
- `scripts/ai/core/memory.sh` — memory_save, memory_search, memory_project_context
- `scripts/ai/core/hydration.sh` — build_context with real data
- `scripts/ai/core/sync.sh` — mirror_project, sync_project_path
- `scripts/ai/core/provider_selector.sh` — all intent routing cases
- `scripts/ai/core/agent_router.sh` — agent-to-provider routing
- `scripts/ai/core/skill_detector.sh` — skill detection from prompt
- `scripts/ai/core/skill_registry.sh` — skill registry operations

**Providers (Phase 2 — HIGH)**
- `scripts/ai/providers/gemini.sh` — run_gemini, QUOTA_EXHAUSTED fallback, generic failure fallback
- `scripts/ai/providers/claude.sh` — run_claude, env vars, missing binary
- `scripts/ai/providers/opencode.sh` — run_opencode, missing binary
- `scripts/ai/providers/gentle.sh` — gentle_sync, gentle_upgrade, gentle_refresh_skills

**Entry Point & Integration (Phase 3 — HIGH)**
- `scripts/ai/ai.sh` — main entry point (292 lines), all bootstrap and routing logic
- `scripts/ai/core/router.sh` — all provider routing cases end-to-end

**Launcher Scripts (Phase 4 — MEDIUM)**
- `scripts/ai/menu.sh` — Menu choices, script invocation
- `scripts/ai/utils.sh` — session_exists, attach_or_switch, create_session
- `scripts/ai/workspace.sh` — Template selection, layout application
- `scripts/ai/popup.sh`, `scripts/ai/sessions.sh`, etc.

**Templates (Phase 4 — MEDIUM)**
- `scripts/ai/templates/*.sh` — build_layout functions for all 4 templates (default, mobile, node, remote)

**Error Paths (Phase 5 — MEDIUM)**
- Empty prompt handling (`ai.sh` with no args)
- Missing `.env` file (providers sourcing without error handling)
- TMUX unavailable (graceful failure)
- Network offline (`detect_network` returns offline)
- Provider binary missing (fallback chains work)
- Malformed project directories

**Bug Fixes (Concurrent with Phase 1)**
- Fix hardcoded `$HOME/dotfiles` in `scripts/debian/bootstrap/ai.sh` (line 5)
- Fix hardcoded `$HOME/dotfiles` in `scripts/ai/core/router.sh` (lines 7-11)
- Fix hardcoded paths in `scripts/ai/menu.sh`
- Fix `recovery.md` line 557 wrong repo URL (`ipproyectosysoluciones/termux-dotfiles` → `bladimir/Termux-AI-Astaroth`)

### Out of Scope (for now)

- **SSH device test automation** — Manual test execution via SSH is acceptable for initial TDD work
- **CI/CD pipeline** — No GitHub Actions or automated CI for this phase
- **Non-AI scripts** — `scripts/debian/bootstrap/` (Debian setup), `scripts/zsh/` (pure zsh configs)
- **Performance testing** — Load testing, stress testing
- **Security audit** — Pen testing, vulnerability scanning

---

## Approach

### Phased by Risk/Impact

```
Phase 1 (CRITICAL)  → Core modules (project, runtime, state, memory, hydration, sync)
Phase 2 (HIGH)      → Providers (gemini, claude, opencode, gentle)
Phase 3 (HIGH)      → Integration (ai.sh, router.sh)
Phase 4 (MEDIUM)    → Launchers and templates (menu, utils, workspace, templates)
Phase 5 (MEDIUM)    → Error paths (empty prompt, no tmux, offline, missing binary)
```

### TDD Strict Compliance

1. **RED**: Write failing test for each function/behavior
2. **Verify RED**: Run test, confirm it fails for expected reason
3. **GREEN**: Write minimal code to pass test
4. **Verify GREEN**: Run test, confirm it passes
5. **REFACTOR**: Clean up code (only after green)

**No exceptions**: If a test passes immediately, it's testing existing behavior — fix the test.

### Test Structure

- Framework: `bats` (Bash Automated Testing System)
- Location: `tests/` directory
- Naming: `phase{N}/{module_name}.bats`
- Helper: `tests/test_helper.bash` (extend as needed)

### SSH Device Testing

For devices (Termux phone), tests run via:
```bash
ssh phone-ai -p 8022 "cd ~/dotfiles && bats --recursive tests/"
```

Tests are developed locally and verified on device via SSH connection.

---

## Rollback Plan

**Strategy**: Each phase is independently revertable via `git revert`.

- Phase 1 commits are independently revertable
- Phase 2 commits are independently revertable
- etc.

**Test addition policy**: Tests are added, never existing functionality removed. This ensures rollback only removes test coverage, never breaks existing behavior.

**Git workflow**:
```bash
# Revert a specific phase
git revert <phase-commit-hash>

# Partial rollback if needed
git revert <commit1> <commit2>
```

---

## Artifacts

| Artifact | Location |
|----------|----------|
| Exploration | `openspec/changes/Test-Apply/exploration.md` |
| Proposal | `openspec/changes/Test-Apply/proposal.md` |
| Spec | `openspec/changes/Test-Apply/spec.md` (future) |
| Design | `openspec/changes/Test-Apply/design.md` (future) |
| Tasks | `openspec/changes/Test-Apply/tasks.md` (future) |
| Engram | `sdd/Test-Apply/proposal` |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-------------|
| Hardcoded paths in tests | HIGH | MEDIUM | Use `test_helper.bash` to resolve paths dynamically |
| TMUX not available in CI | HIGH | LOW | Skip tmux-dependent tests, test manually on device |
| Provider API mocking complex | MEDIUM | MEDIUM | Mock at shell level with `bats-mock` stubs |
| SSH connection flaky | MEDIUM | LOW | Run tests locally when possible, device tests are supplementary |
| Tests pollute tmux session state | MEDIUM | MEDIUM | Clean up sessions in teardown, use unique session names |

---

## Work Units

Based on `work-unit-commits` skill, commits will be structured as:

```
feat(tests): add project.sh detection tests
feat(tests): add runtime detection tests
fix(paths): use dirname BASH_SOURCE for bootstrap paths
feat(tests): add state management tests
feat(tests): add memory integration tests
... (continues per phase)
```

Each commit is independently reviewable and revertable.

---

## Next

Proceed to **sdd-spec** to write detailed requirements and scenarios for each phase.

---

*Proposal created: 2026-06-02*
*Author: sdd-propose sub-agent*
*Skill Resolution: paths-injected — 3 skills (issue-creation, test-driven-development, work-unit-commits)*