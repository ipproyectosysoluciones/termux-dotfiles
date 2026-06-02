# Exploration: AI-Workspace

## Topic
Improve and fix the AI Workspace framework — documentation gaps, code bugs, and architectural inconsistencies.

---

## Current State

### What the docs say (ai-workspace.md)
The architecture diagram shows only top-level launchers:
```
scripts/ai/
├── menu.sh
├── popup.sh
├── workspace.sh
├── sessions.sh
├── utils.sh
├── ui.sh
├── nvim.sh
├── opencode.sh
├── gentle.sh
└── engram.sh
```

### What the code actually has
```
scripts/ai/
├── ai.sh                    # main entry point
├── menu.sh                  # launcher menu
├── popup.sh
├── workspace.sh             # empty wrapper (sources utils.sh only)
├── sessions.sh
├── utils.sh
├── ui.sh
├── nvim.sh
├── opencode.sh
├── gentle.sh
├── engram.sh
├── core/
│   ├── agent_context.sh
│   ├── agent_registry.sh
│   ├── agent_router.sh
│   ├── capability_router.sh
│   ├── context.sh
│   ├── doctor.sh
│   ├── executor.sh
│   ├── hooks.sh
│   ├── hydration.sh
│   ├── intelligence.sh
│   ├── layout.sh
│   ├── memory.sh
│   ├── metadata.sh
│   ├── orchestrator.sh
│   ├── paths.sh
│   ├── policies.sh
│   ├── project.sh
│   ├── provider_selector.sh
│   ├── registry.sh
│   ├── routing.sh
│   ├── runtime.sh
│   ├── runtime_session.sh
│   ├── session.sh
│   ├── skill_detector.sh
│   ├── skill_registry.sh
│   ├── state.sh
│   ├── subagent_registry.sh
│   ├── subagent_runtime.sh
│   └── workspace.sh
├── providers/
│   ├── claude.sh
│   ├── gentle.sh
│   ├── gemini.sh
│   ├── mistral.sh          # EXISTS but not wired
│   └── opencode.sh
├── runtime/
│   └── ai-runtime.sh
└── templates/
    ├── default.sh
    ├── mobile.sh
    ├── node.sh
    └── remote.sh
```

---

## Gap Analysis

### Documentation vs Reality

| Doc Says | Code Has | Gap |
|----------|----------|-----|
| `scripts/ai/` with 10 files | `scripts/ai/` with 10 files + 29 core modules + 5 providers + 4 templates + runtime | **CRITICAL** — docs show launcher scripts only, ignore the entire orchestration layer |
| `provider-architecture.md` table: Gemini, OpenCode, Gentle | Providers: claude, gentle, gemini, mistral, opencode | **CRITICAL** — Mistral missing from docs |
| `workspace.sh` (launcher) is documented as part of full workspace mode | `scripts/ai/workspace.sh` is essentially empty — only sources `utils.sh` | **CRITICAL** — workspace launcher is non-functional stub |
| `ai-workspace.md` future directions mentions "workspace profiles" | No workspace profile system exists | **MODERATE** |
| Provider fallback chain: gemini → opencode → gentle | `ai-runtime.sh` doesn't source `mistral.sh`; `provider_selector.sh` has mistral intent but runtime can't run it | **GRAVE** — Mistral unreachable |

### Hardcoded Paths
- `ai.sh` line 5: `BASE_DIR="$HOME/dotfiles/scripts/ai"`
- `router.sh` line 3-6: sources use `$HOME/dotfiles/...`
- `ai-runtime.sh` line 15: `BASE_DIR="$HOME/dotfiles/scripts/ai"`
- `menu.sh` line 3: `source "$HOME/dotfiles/scripts/ai/utils.sh"`
- `menu.sh` line 21-34: hardcoded `~/dotfiles/scripts/ai/...` paths

This affects portability — the framework assumes `$HOME/dotfiles` and fails if installed elsewhere.

---

## Issues Found

### CRITICAL

**1. Documentation architecture diagram is incomplete**
- **File**: `docs/ai-workspace.md` (lines 38-49)
- **Problem**: Shows only top-level launchers. Missing `core/`, `providers/`, `runtime/`, `templates/` directories and all orchestration modules.
- **Fix**: Update diagram to show full architecture. Document core orchestration layer.

**2. `provider-architecture.md` missing Mistral in provider table**
- **File**: `docs/provider-architecture.md` (lines 28-32)
- **Problem**: Table lists only Gemini, OpenCode, Gentle. Mistral was added to `providers/mistral.sh` but not documented.
- **Fix**: Add Mistral to provider table with status and script path.

### GRAVE

**3. `ai-runtime.sh` does not source `mistral.sh`**
- **File**: `scripts/ai/runtime/ai-runtime.sh` (lines 38-41)
- **Problem**: Sources opencode, gemini, claude, gentle. Missing `mistral.sh`.
- **Impact**: `provider_selector.sh` has `mistral` intent routing (lines 65-77) but runtime cannot execute Mistral.
- **Fix**: Add `source "$BASE_DIR/providers/mistral.sh"` after line 41.

**4. `workspace.sh` (launcher) is a non-functional stub**
- **File**: `scripts/ai/workspace.sh` (3 lines)
- **Problem**: Only `source "$HOME/dotfiles/scripts/ai/utils.sh"`. Does nothing else.
- **Impact**: "Full Workspace" menu option in `menu.sh` calls this but it has no logic.
- **Fix**: Implement workspace launcher to coordinate multiple runtimes or use template system.

### MODERATE

**5. `route_agent_provider` missing mistral route**
- **File**: `scripts/ai/core/agent_router.sh`
- **Problem**: `route_agent_provider` function only routes: rag-agent → gemini, kubernetes-agent → opencode, mern-agent → claude, terminal-agent → opencode, editor-agent → claude. No route for "mistral" intent.
- **Note**: `provider_selector.sh` already has mistral intent case (lines 65-77), but `agent_router.sh` doesn't.
- **Fix**: Add mistral case to `route_agent_provider`.

**6. No documentation for agent/subagent framework**
- **Files**: `core/orchestration.sh`, `core/subagent_registry.sh`, `core/subagent_runtime.sh`, `core/agent_registry.sh`, `core/agent_router.sh`
- **Problem**: These are completely undocumented. The orchestration layer is invisible.
- **Fix**: Create `docs/orchestration.md` explaining agents, subagents, capability routing.

**7. `$HOME/dotfiles/` hardcoded in multiple files**
- **Files**: `ai.sh` (5), `router.sh` (3-6), `ai-runtime.sh` (15), `menu.sh` (3, 21-34), `core/intelligence.sh` (3), `core/layout.sh` (3), `core/paths.sh`
- **Problem**: Framework only works if installed at `$HOME/dotfiles`. Not portable.
- **Fix**: Use relative paths or detect actual script location via `$(dirname "${BASH_SOURCE[0]}")`.

### LOW

**8. `core/workspace.sh` is minimal**
- **File**: `scripts/ai/core/workspace.sh` (77 lines)
- **Problem**: Only has `ensure_workspace()`, metadata helpers. No active workspace management.
- **Fix**: Expand workspace management or consolidate with `scripts/ai/workspace.sh`.

**9. No workspace profiles**
- **Doc**: `docs/ai-workspace.md` "Future Directions" mentions profiles
- **Problem**: No implementation exists.
- **Fix**: Low priority — future enhancement.

---

## Documentation Needs

| Document | Action | Priority |
|-----------|--------|----------|
| `docs/ai-workspace.md` | Rewrite architecture section with full tree | CRITICAL |
| `docs/provider-architecture.md` | Add Mistral to provider table | CRITICAL |
| `docs/orchestration.md` | Create new — explain agent/subagent framework | MODERATE |
| `docs/ai-workspace.md` | Document `ai-runtime.sh` execution flow | MODERATE |

---

## Recommended Approach

### Phase 1: Fix Critical Bugs (Quick Wins)
1. Add `mistral.sh` sourcing to `ai-runtime.sh`
2. Add Mistral to `provider-architecture.md` table
3. Update `ai-workspace.md` architecture diagram

### Phase 2: Fix Functional Gaps
4. Implement `workspace.sh` launcher stub
5. Add mistral route to `route_agent_provider`
6. Fix `$HOME/dotfiles/` hardcoding in key files

### Phase 3: Documentation
7. Create `docs/orchestration.md` for agent/subagent framework
8. Document runtime execution flow

### Phase 4: Future Work (Out of Scope)
9. Workspace profiles system
10. Expand `core/workspace.sh` capabilities

---

## Risks

- **Risk**: Changing `ai-runtime.sh` provider sourcing may break existing fallback chains
- **Risk**: Hardcoded path fixes could affect existing tmux sessions that depend on current behavior
- **Risk**: `workspace.sh` implementation may require coordination with template system

---

## Ready for Proposal

**Yes.** The exploration is complete. Key findings:

1. **CRITICAL**: Documentation shows only top-level scripts, ignores entire `core/` orchestration layer
2. **CRITICAL**: Mistral missing from provider docs; exists in code but not wired in runtime
3. **GRAVE**: `ai-runtime.sh` doesn't source `mistral.sh` — Mistral unreachable despite router support
4. **GRAVE**: `workspace.sh` is an empty stub — "Full Workspace" menu option does nothing
5. **MODERATE**: Hardcoded `$HOME/dotfiles/` paths throughout — portability issue
6. **MODERATE**: Agent/subagent framework completely undocumented

The change encompasses: fixing runtime wiring, updating architecture docs, implementing workspace launcher, and documenting the orchestration layer.