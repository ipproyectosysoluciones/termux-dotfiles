# Tasks: AI-Workspace

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~440 (440 over 4 phases) |
| 400-line budget risk | **Medium** |
| Chained PRs recommended | **Yes** |
| Delivery strategy | ask-always |
| Suggested split | 3 chained PRs (see Work Units below) |

Decision needed before apply: **Yes**
Chained PRs recommended: **Yes**
Chain strategy: **pending** (awaiting user decision)
400-line budget risk: **Medium**

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Phase 1 (docs fix) + Phase 2 (runtime wiring) — portable paths affect these files too | PR 1 → main | ~180 lines; self-contained |
| 2 | Phase 4 (path hardcoding fix) — 7 files, all path fixes | PR 2 → main | ~180 lines; independent but cleaner after runtime wiring lands |
| 3 | Phase 3 (orchestration doc) — new file, ~150 lines | PR 3 → main | ~150 lines; purely documentation |

---

## Phase 1: Documentation Fix

### P1-T1: Update ai-workspace.md architecture diagram

- **Description**: Rewrite the Architecture section in `docs/ai-workspace.md` (lines 37-49) to show the full directory tree — all 10 top-level scripts, all 29 core modules, 5 providers, 4 templates, and runtime. Reference the core orchestration layer (orchestrator, agent_registry, subagent_registry, agent_router, capability_router).
- **Files affected**: `docs/ai-workspace.md`
- **Verification**: Diagram visually shows `core/`, `providers/`, `runtime/`, `templates/` subtrees; mentions orchestrator and related modules
- **Dependencies**: None
- **Estimated lines**: ~60
- **Status**: [x] Complete

### P1-T2: Add Mistral to provider-architecture.md table

- **Description**: Add Mistral row to the Current Providers table in `docs/provider-architecture.md` (after line 32). Mistral path = `scripts/ai/providers/mistral.sh`. Status = secondary/fallback. Also update Fallback Chain section to reflect Mistral position (after OpenCode, before Gentle).
- **Files affected**: `docs/provider-architecture.md`
- **Verification**: Table lists all 5 providers (claude, gentle, gemini, mistral, opencode); Mistral row has script path and status
- **Dependencies**: None
- **Estimated lines**: ~15
- **Status**: [x] Complete

---

## Phase 2: Runtime Wiring

### P2-T1: Add mistral.sh to router.sh provider sources

- **Description**: Add `source "$HOME/dotfiles/scripts/ai/providers/mistral.sh"` to `scripts/ai/core/router.sh` after the existing provider sources (after line 6). This is the authoritative location per resolved design decision #1.
- **Files affected**: `scripts/ai/core/router.sh`
- **Verification**: `source router.sh` in a test shell makes `run_mistral` available
- **Dependencies**: None
- **Estimated lines**: ~1
- **Status**: [x] Complete (combined with dynamic path fix per resolved design decision #1)

### P2-T2: Remove redundant provider sources from ai-runtime.sh

- **Description**: Remove lines 38-41 from `scripts/ai/runtime/ai-runtime.sh` that individually source opencode, gemini, claude, gentle. These are now redundant since `router.sh` sources them all. Keep mistral.sh added via T2-T3.
- **Files affected**: `scripts/ai/runtime/ai-runtime.sh`
- **Verification**: `ai-runtime.sh` still sources all providers via `router.sh`; no duplicate sourcing
- **Dependencies**: P2-T1 (router.sh must source mistral.sh before this removal is safe)
- **Estimated lines**: ~-4 (deletion)
- **Status**: [x] Complete

### P2-T3: Add mistral case to run_provider in router.sh

- **Description**: Add mistral case to the `run_provider` function in `scripts/ai/core/router.sh` (after gentle block, before default). Pattern: `mistral) run_mistral "$@" ;;`
- **Files affected**: `scripts/ai/core/router.sh`
- **Verification**: `run_provider "mistral" "test"` calls `run_mistral`; does not fall through to unknown provider error
- **Dependencies**: P2-T1
- **Estimated lines**: ~8
- **Status**: [x] Complete

### P2-T4: Add mistral route to agent_router.sh

- **Description**: Add mistral case to `route_agent_provider()` in `scripts/ai/core/agent_router.sh` (after editor-agent block, before default). Pattern: `if [[ "$agent" == "mistral" ]]; then echo "mistral"; return; fi`
- **Files affected**: `scripts/ai/core/agent_router.sh`
- **Verification**: `route_agent_provider "mistral"` echoes "mistral"
- **Dependencies**: None
- **Estimated lines**: ~5
- **Status**: [x] Complete

### P2-T5: Implement functional workspace.sh launcher

- **Description**: Replace the 3-line stub in `scripts/ai/workspace.sh` with a functional launcher that: (1) detects its own location via `BASH_SOURCE[0]` and derives `BASE_DIR`; (2) sources `utils.sh` and `core/workspace.sh`; (3) accepts optional template name arg (default, mobile, node, remote) with fallback to `detect_runtime()` from `core/runtime.sh`; (4) sources the template and applies the layout via `apply_layout` from `core/layout.sh`.
- **Files affected**: `scripts/ai/workspace.sh`
- **Verification**: `workspace.sh` (no args) produces observable output; `workspace.sh mobile` loads mobile template; no error about missing utils.sh
- **Dependencies**: None
- **Estimated lines**: ~25
- **Status**: [x] Complete

---

## Phase 3: Orchestration Documentation

### P3-T1: Create docs/orchestration.md

- **Description**: Create `docs/orchestration.md` documenting the agent/subagent orchestration layer. Cover: orchestrator.sh (orchestration coordinator), agent_registry.sh (agent resolution from skills), subagent_registry.sh (subagent registry), subagent_runtime.sh (subagent spawning), agent_router.sh (agent→provider routing), capability_router.sh (skill-to-intent routing via `route_capability`). Include a data flow diagram (prompt → routing → capability → agent → orchestration → subagent → runtime). Aim for >100 lines.
- **Files affected**: `docs/orchestration.md` (new)
- **Verification**: File exists and is non-empty (>100 lines); mentions all 6 modules by name; documents the agent resolution flow
- **Dependencies**: None
- **Estimated lines**: ~150
- **Status**: [x] Complete

---

## Phase 4: Path Hardcoding Fix

### P4-T1: Make ai.sh use dynamic BASE_DIR detection

- **Description**: Replace line 5 `BASE_DIR="$HOME/dotfiles/scripts/ai"` in `scripts/ai/ai.sh` with dynamic detection: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` then `BASE_DIR="$(dirname "$SCRIPT_DIR")"`. Also fix tmux path references at lines 217, 230, 233, 270, 289 that hardcode `$HOME/dotfiles/scripts/ai/...`.
- **Files affected**: `scripts/ai/ai.sh`
- **Verification**: `ai.sh` contains no literal `$HOME/dotfiles/`; script runs from symlinked or alternate installation path
- **Dependencies**: None
- **Estimated lines**: ~30
- **Status**: [x] Complete

### P4-T2: Make ai-runtime.sh use dynamic BASE_DIR detection

- **Description**: Replace line 15 `BASE_DIR="$HOME/dotfiles/scripts/ai"` in `scripts/ai/runtime/ai-runtime.sh` with dynamic detection using `$(dirname "${BASH_SOURCE[0]}")/../..` pattern. Note: individual provider sources (lines 38-41) are already marked for removal in P2-T2; after that, the only remaining hardcoded path is the BASE_DIR assignment.
- **Files affected**: `scripts/ai/runtime/ai-runtime.sh`
- **Verification**: `ai-runtime.sh` contains no literal `$HOME/dotfiles/`; `AI_PROVIDER=mistral ./ai-runtime.sh mistral "test"` works from any CWD
- **Dependencies**: P2-T2 (removal of redundant provider sources)
- **Estimated lines**: ~5
- **Status**: [x] Complete

### P4-T3: Make router.sh use dynamic provider paths

- **Description**: Replace lines 3-6 in `scripts/ai/core/router.sh` that hardcode `$HOME/dotfiles/scripts/ai/providers/` with `$(dirname "${BASH_SOURCE[0]}")/providers/` for each source. Note: after P2-T1 and P2-T3, mistral.sh will be in the same sources block, so this fix also covers the mistral sourcing path.
- **Files affected**: `scripts/ai/core/router.sh`
- **Verification**: `router.sh` sources all providers without any hardcoded home path; `run_provider "mistral" "test"` resolves correctly
- **Dependencies**: P2-T1, P2-T3
- **Estimated lines**: ~8
- **Status**: [x] Complete

### P4-T4: Make menu.sh use dynamic script paths

- **Description**: Replace hardcoded `~/dotfiles/scripts/ai/...` paths at lines 3 and 21-34 in `scripts/ai/menu.sh` with dynamic detection using `BASH_SOURCE[0]` pattern. All menu options that invoke scripts (workspace, sessions, ai-runtime, etc.) must resolve via dynamic `BASE_DIR`.
- **Files affected**: `scripts/ai/menu.sh`
- **Verification**: Menu displays and all options invoke correct scripts regardless of CWD
- **Dependencies**: None
- **Estimated lines**: ~25
- **Status**: [x] Complete

### P4-T5: Make core/intelligence.sh use dynamic path

- **Description**: Replace hardcoded `source "$HOME/dotfiles/scripts/ai/core/state.sh"` at line 3 in `scripts/ai/core/intelligence.sh` with `$(dirname "${BASH_SOURCE[0]}")/state.sh` relative path.
- **Files affected**: `scripts/ai/core/intelligence.sh`
- **Verification**: `intelligence.sh` sources `state.sh` from any installation path; `resume_last_session` works
- **Dependencies**: None
- **Estimated lines**: ~3
- **Status**: [x] Complete

### P4-T6: Make core/layout.sh use dynamic template paths

- **Description**: Replace hardcoded `$HOME/dotfiles/scripts/ai/templates/` references at lines 3 and 55 in `scripts/ai/core/layout.sh` with dynamic path detection. Also fix the `source "$BASE_DIR/runtime/runtime.sh"` reference to use dynamic BASE_DIR.
- **Files affected**: `scripts/ai/core/layout.sh`
- **Verification**: `apply_layout` resolves templates from any installation path
- **Dependencies**: None
- **Estimated lines**: ~8
- **Status**: [x] Complete

### P4-T7: Add XDG_STATE_HOME support to core/workspace.sh

- **Description**: In `scripts/ai/core/workspace.sh`, update `WORKSPACE_DB` to use `XDG_STATE_HOME/ai/workspaces` when `XDG_STATE_HOME` is set, falling back to `$HOME/.ai/workspaces` otherwise. This satisfies the spec requirement.
- **Files affected**: `scripts/ai/core/workspace.sh`
- **Verification**: `WORKSPACE_DB` is set to `$XDG_STATE_HOME/ai/workspaces` when that env var is exported; falls back correctly when not set
- **Dependencies**: None
- **Estimated lines**: ~8
- **Status**: [x] Complete

---

## Task Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| Phase 1 | P1-T1, P1-T2 | Documentation fix |
| Phase 2 | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5 | Runtime wiring |
| Phase 3 | P3-T1 | Orchestration documentation |
| Phase 4 | P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6, P4-T7 | Path portability |
| **Total** | **16 tasks** | |

## Implementation Order

1. **P1-T1, P1-T2** (Phase 1) — Documentation only, no code risk
2. **P2-T1, P2-T3** (Phase 2 part 1) — router.sh mistral wiring, prerequisite for P2-T2
3. **P2-T2** (Phase 2 part 2) — Remove redundant ai-runtime.sh sources (depends on P2-T1)
4. **P2-T4, P2-T5** (Phase 2 part 3) — agent_router.sh mistral route + workspace.sh implementation
5. **P3-T1** (Phase 3) — New documentation file, isolated
6. **P4-T1 through P4-T7** (Phase 4) — Path fixes across 7 files; apply after Phase 2 changes are stable

## Recommendation

The total is ~440 lines across 12 files (2 created, 10 modified). This exceeds the 400-line review budget, so chained PRs are recommended. With `ask-always` delivery strategy, the orchestrator should ask which chain strategy to use before apply:

- **Stacked-to-main**: fastest, each PR is independently mergeable
- **Feature-branch-chain**: safer rollback control, each child PR targets the previous PR branch
- **size:exception**: single PR if maintainer approves the overage