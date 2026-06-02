# Proposal: AI-Workspace

## Intent

Bring AI Workspace documentation and code in sync, fix the Mistral provider wiring bug, implement the non-functional workspace launcher, and improve framework portability. The exploration found 9 issues ranging from missing architecture diagrams to broken runtime routing.

## Scope

### In Scope
- `docs/ai-workspace.md` — update architecture diagram to show full `core/`, `providers/`, `runtime/`, `templates/` layers
- `docs/provider-architecture.md` — add Mistral to provider table
- `scripts/ai/runtime/ai-runtime.sh` — add `source mistral.sh`
- `scripts/ai/workspace.sh` — implement launcher stub
- `scripts/ai/core/agent_router.sh` — add mistral route to `route_agent_provider`
- `docs/orchestration.md` — new doc for agent/subagent framework
- Hardcoded `$HOME/dotfiles/` paths in key files (`ai.sh`, `ai-runtime.sh`, `menu.sh`, `core/intelligence.sh`, `core/layout.sh`, `core/paths.sh`)

### Out of Scope
- Workspace profiles system (future enhancement)
- `core/workspace.sh` expansion beyond current scope
- Additional providers beyond existing five

## Capabilities

### New Capabilities
- `orchestration-framework`: Document the agent/subagent orchestration layer (orchestrator.sh, agent_registry.sh, subagent_registry.sh, subagent_runtime.sh, agent_router.sh, capability_router.sh)

### Modified Capabilities
- None at spec level — all fixes are implementation-only

## Approach

Four phased batches respecting the 400-line review budget:

**Phase 1 — Documentation fixes** (~100 lines):
- Update `docs/ai-workspace.md` architecture diagram
- Add Mistral to `docs/provider-architecture.md` table

**Phase 2 — Runtime wiring** (~120 lines):
- Add `mistral.sh` sourcing to `ai-runtime.sh`
- Add mistral route to `agent_router.sh`
- Implement `workspace.sh` launcher stub

**Phase 3 — New orchestration doc** (~150 lines):
- Create `docs/orchestration.md` explaining agents, subagents, capability routing

**Phase 4 — Path hardcoding fix** (~130 lines):
- Replace `$HOME/dotfiles/` with `$(dirname "${BASH_SOURCE[0]}")` based detection in `ai.sh`, `ai-runtime.sh`, `menu.sh`, `core/intelligence.sh`, `core/layout.sh`, `core/paths.sh`

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `docs/ai-workspace.md` | Modified | Full architecture diagram rewrite |
| `docs/provider-architecture.md` | Modified | Mistral added to provider table |
| `docs/orchestration.md` | New | Agent/subagent framework documentation |
| `scripts/ai/runtime/ai-runtime.sh` | Modified | Add mistral.sh sourcing |
| `scripts/ai/workspace.sh` | Modified | Implement launcher logic |
| `scripts/ai/core/agent_router.sh` | Modified | Add mistral route |
| `scripts/ai/ai.sh` | Modified | Fix hardcoded path |
| `scripts/ai/menu.sh` | Modified | Fix hardcoded paths |
| `scripts/ai/core/intelligence.sh` | Modified | Fix hardcoded path |
| `scripts/ai/core/layout.sh` | Modified | Fix hardcoded path |
| `scripts/ai/core/paths.sh` | Modified | Fix hardcoded path |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Mistral sourcing change breaks fallback chain | Medium | Test with `AI_PROVIDER=mistral ./ai-runtime.sh` |
| Hardcoded path fixes break existing tmux sessions | Medium | Changes are backward-compatible if detected at runtime |
| `workspace.sh` implementation conflicts with template system | Low | Use template loader pattern already in `templates/` |

## Rollback Plan

1. Revert `ai-runtime.sh` to remove mistral sourcing (1 line change)
2. Revert `agent_router.sh` to remove mistral route
3. Revert `workspace.sh` to original 3-line stub
4. Restore hardcoded paths in affected files
5. Delete `docs/orchestration.md`
6. Restore `docs/ai-workspace.md` and `docs/provider-architecture.md` from git

## Dependencies

- None — all work is self-contained

## Success Criteria

- [ ] `AI_PROVIDER=mistral` routes correctly through `ai-runtime.sh`
- [ ] `docs/ai-workspace.md` shows full directory tree including `core/`, `providers/`, `runtime/`, `templates/`
- [ ] `docs/provider-architecture.md` lists all 5 providers (claude, gentle, gemini, mistral, opencode)
- [ ] `workspace.sh` launches and coordinates the workspace template system
- [ ] Agent router has mistral route matching provider_selector.sh intent
- [ ] All files use relative/dynamic paths instead of `$HOME/dotfiles/`
- [ ] `docs/orchestration.md` documents orchestrator.sh, agent_registry.sh, subagent_registry.sh, subagent_runtime.sh