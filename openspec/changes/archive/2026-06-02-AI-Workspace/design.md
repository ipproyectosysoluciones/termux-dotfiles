# Design: AI-Workspace

## Technical Approach

Four phased batches to fix documentation gaps, wire Mistral provider into runtime, implement the non-functional workspace launcher, and replace hardcoded `$HOME/dotfiles/` paths with dynamic path detection. Each phase is independently revertable and fits within the 400-line review budget.

---

## Phase 1 — Documentation Fix

### Technical Approach

Rewrite `docs/ai-workspace.md` architecture section to show the full directory tree (`core/`, `providers/`, `runtime/`, `templates/`). Add Mistral to `docs/provider-architecture.md` provider table with script path and status. The architecture diagram update is a direct documentation fix — no code changes.

### Component Changes

| File | Action | Description |
|------|--------|-------------|
| `docs/ai-workspace.md` | Modify | Replace architecture diagram (lines 37-49) with full tree showing 10 top-level scripts + 29 core modules + 5 providers + 4 templates + runtime. Document core orchestration layer. |
| `docs/provider-architecture.md` | Modify | Add Mistral row to provider table (after line 32), update fallback chain to include Mistral. |

### Data Flow

```
docs/ai-workspace.md   ← updated diagram
docs/provider-architecture.md  ← mistral added to table
```

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Diagram format | ASCII tree | Matches existing doc style, shows hierarchy clearly |
| Mistral position in table | After OpenCode, before Gentle | Maintains primary→fallback ordering |

### Rollback Strategy

`git restore docs/ai-workspace.md docs/provider-architecture.md` — single git command restores both files to prior state.

---

## Phase 2 — Runtime Wiring

### Technical Approach

Three separate fixes to wire Mistral into the runtime and implement the workspace launcher:

1. **ai-runtime.sh**: Add `source "$BASE_DIR/providers/mistral.sh"` after line 41 (after the existing provider block). This follows the existing sourcing pattern exactly.

2. **agent_router.sh**: Add a mistral case to `route_agent_provider()` function. The pattern mirrors the existing 5 agent→provider mappings. When `$agent == "mistral"`, echo "mistral".

3. **workspace.sh (launcher)**: Replace the 3-line stub with a functional launcher that:
   - Detects its own location via `BASH_SOURCE[0]`
   - Accepts optional template argument (default, mobile, node, remote)
   - Sources `utils.sh` for helpers
   - Creates a tmux session named "workspace" if not exists
   - Sources the appropriate template and applies the layout
   - Uses `ensure_workspace` from `core/workspace.sh` for session management

### Component Changes

| File | Action | Description |
|------|--------|-------------|
| `scripts/ai/runtime/ai-runtime.sh` | Modify | Add `source "$BASE_DIR/providers/mistral.sh"` after line 41 |
| `scripts/ai/core/agent_router.sh` | Modify | Add mistral case to `route_agent_provider()` (after terminal-agent block, ~5 lines) |
| `scripts/ai/workspace.sh` | Modify | Replace 3-line stub with functional launcher (~25 lines) |

### Data Flow

```
ai-runtime.sh
  └─ sources router.sh
       └─ sources mistral.sh (NEW)
            └─ run_mistral() available

agent_router.sh
  └─ route_agent_provider("mistral") → echo "mistral" (NEW)

workspace.sh (launcher)
  └─ sources utils.sh
  └─ sources core/workspace.sh
  └─ creates tmux session "workspace"
  └─ sources templates/<template>.sh
  └─ applies layout
```

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Mistral sourcing position | After existing providers (line 41) | Matches existing pattern; mistral is secondary provider, not primary |
| workspace.sh approach | Template-based launcher | Spec says "use template loader pattern from templates/"; existing templates (default, mobile, node, remote) already exist |
| tmux session name | "workspace" | Simple, predictable, avoids conflicts with project sessions |

### Rollback Strategy

1. Remove mistral sourcing from `ai-runtime.sh` (1 line)
2. Remove mistral case from `agent_router.sh` (5 lines)
3. Revert `workspace.sh` to original 3-line stub

---

## Phase 3 — Orchestration Documentation

### Technical Approach

Create `docs/orchestration.md` explaining the agent/subagent orchestration layer. Document the 6 core modules: `orchestrator.sh`, `agent_registry.sh`, `subagent_registry.sh`, `subagent_runtime.sh`, `agent_router.sh`, `capability_router.sh`. Use the cognitive-doc-design skill pattern: lead with the outcome, progressive disclosure, chunking, signposting.

### Component Changes

| File | Action | Description |
|------|--------|-------------|
| `docs/orchestration.md` | Create | New doc explaining orchestration framework (~150 lines) |

### Data Flow

```
prompt → routing.sh → route_capability() → capability_router.sh
                                     ↓
                              resolve_agent() → agent_registry.sh
                                     ↓
                              route_agent_provider() → agent_router.sh
                                     ↓
                              orchestrate_agents() → orchestration.sh
                                     ↓
                              resolve_subagents() → subagent_registry.sh
                                     ↓
                              spawn_subagents() → subagent_runtime.sh
```

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Document scope | 6 core modules only | Spec defines these; broader scope exceeds 150-line budget |
| Style | Reference-style with flow diagram | Allows quick lookup; progressive disclosure for each module |
| Mistral mention | In agent_router section | Mistral is a valid agent intent routed by agent_router |

### Rollback Strategy

`rm docs/orchestration.md` — single file deletion.

---

## Phase 4 — Path Hardcoding Fix

### Technical Approach

Replace all hardcoded `$HOME/dotfiles/` references with dynamic `$(dirname "${BASH_SOURCE[0]}")` based path detection. The pattern:

```bash
# Before (all files)
BASE_DIR="$HOME/dotfiles/scripts/ai"

# After (ai.sh, ai-runtime.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"  # goes up one level from scripts/ai to dotfiles
```

For files at `scripts/ai/*`: `BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"`
For files at `scripts/ai/core/*`: `BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"`
For files at `scripts/ai/runtime/*`: `BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"`

The `core/paths.sh` already uses hardcoded Termux/Debian paths but does NOT use `$HOME/dotfiles/` — it uses `/data/data/com.termux/files/home` and `/home/dev`. It does not need modification.

### Component Changes

| File | Action | Description |
|------|--------|-------------|
| `scripts/ai/ai.sh` | Modify | Replace line 5 `BASE_DIR="$HOME/dotfiles/scripts/ai"` with dynamic detection; fix lines 217, 230, 233, 270, 289 tmux paths |
| `scripts/ai/runtime/ai-runtime.sh` | Modify | Replace line 15 `BASE_DIR="$HOME/dotfiles/scripts/ai"` with dynamic detection |
| `scripts/ai/core/router.sh` | Modify | Replace lines 3-6 `$HOME/dotfiles/scripts/ai/providers/` with `$(dirname "${BASH_SOURCE[0]}")/providers/` |
| `scripts/ai/menu.sh` | Modify | Replace lines 3, 21-34 hardcoded paths with relative detection |
| `scripts/ai/core/intelligence.sh` | Modify | Replace line 3 hardcoded path with dynamic detection |
| `scripts/ai/core/layout.sh` | Modify | Replace lines 3, 55 hardcoded paths with dynamic detection |
| `scripts/ai/core/workspace.sh` | Modify | Add `XDG_STATE_HOME` support for `WORKSPACE_DB` (spec requirement: `XDG_STATE_HOME/ai/workspaces` when set) |

### Data Flow

```
Dynamic BASE_DIR
  └─ All source commands use $BASE_DIR
  └─ All tmux paths use $BASE_DIR
  └─ All template paths use $BASE_DIR
```

### Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| BASH_SOURCE[0] vs PWD | BASH_SOURCE[0] | PWD can be anywhere; script location is fixed |
| XDG_STATE_HOME fallback | Use `XDG_STATE_HOME/ai/workspaces` when set | Follows Termux/Android conventions; spec requirement |
| Backward compatibility | Runtime detection only | Does not break existing tmux sessions since env vars are set at launch time |

### Rollback Strategy

Restore hardcoded `$HOME/dotfiles/` in all 7 affected files using `git checkout` on each file.

---

## File Changes Summary

| File | Phase | Action |
|------|-------|--------|
| `docs/ai-workspace.md` | 1 | Modify |
| `docs/provider-architecture.md` | 1 | Modify |
| `scripts/ai/runtime/ai-runtime.sh` | 2, 4 | Modify |
| `scripts/ai/core/agent_router.sh` | 2 | Modify |
| `scripts/ai/workspace.sh` | 2 | Modify |
| `docs/orchestration.md` | 3 | Create |
| `scripts/ai/ai.sh` | 4 | Modify |
| `scripts/ai/core/router.sh` | 4 | Modify |
| `scripts/ai/menu.sh` | 4 | Modify |
| `scripts/ai/core/intelligence.sh` | 4 | Modify |
| `scripts/ai/core/layout.sh` | 4 | Modify |
| `scripts/ai/core/workspace.sh` | 4 | Modify |

**Total: 12 files — 2 created, 10 modified**

---

## Open Questions

- [ ] `router.sh` sources providers at file scope (lines 3-6). Does `ai-runtime.sh` already source `router.sh`, making the top-level sources redundant? Need to verify `router.sh` is only ever sourced from `ai-runtime.sh` or if it's called standalone.
- [ ] `workspace.sh` template argument: should it accept a template name (`default`, `mobile`, `node`, `remote`) or infer from `detect_runtime`? Spec says "with a template name" but implementation may need auto-detection fallback.
- [ ] `core/workspace.sh` `WORKSPACE_DB` change: when `XDG_STATE_HOME` is not set, should it default to `$HOME/.ai/workspaces` (current) or `$HOME/.local/state/ai/workspaces` (XDG fallback)? Spec shows the XDG path as the conditional, not replacement.

---

## Rollback Criteria (per phase)

1. **Phase 1**: `git restore docs/ai-workspace.md docs/provider-architecture.md`
2. **Phase 2**: Remove mistral sourcing (1 line), remove mistral case (5 lines), revert workspace.sh to stub
3. **Phase 3**: `rm docs/orchestration.md`
4. **Phase 4**: `git restore scripts/ai/ai.sh scripts/ai/runtime/ai-runtime.sh scripts/ai/core/router.sh scripts/ai/menu.sh scripts/ai/core/intelligence.sh scripts/ai/core/layout.sh scripts/ai/core/workspace.sh`