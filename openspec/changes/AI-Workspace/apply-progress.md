# Apply Progress: AI-Workspace

## Summary
All 4 phases complete. 16/16 tasks done. Two apply batches: Phase 1+2 (first batch, PR #1 merged) and Phase 3+4 (this batch, PR #2).

## Tasks Completed

### Phase 1: Documentation Fix
- [x] P1-T1: Updated ai-workspace.md architecture diagram with full directory tree (core/, providers/, runtime/, templates/)
- [x] P1-T2: Added Mistral to provider-architecture.md table

### Phase 2: Runtime Wiring
- [x] P2-T1: Added mistral.sh to router.sh with dynamic BASE_DIR detection
- [x] P2-T2: Removed redundant provider sources from ai-runtime.sh (lines 38-41)
- [x] P2-T3: Added mistral case to run_provider() in router.sh
- [x] P2-T4: Added mistral route to agent_router.sh
- [x] P2-T5: Implemented functional workspace.sh launcher with template support

### Phase 3: Orchestration Documentation
- [x] P3-T1: Created docs/orchestration.md (220 lines covering all 6 modules with data flow diagram)

### Phase 4: Path Hardcoding Fix
- [x] P4-T1: Made ai.sh use dynamic BASE_DIR detection (replaced line 5 hardcoded path + all tmux path references)
- [x] P4-T2: Made ai-runtime.sh use dynamic BASE_DIR detection (replaced line 15 hardcoded path)
- [x] P4-T3: Made router.sh use dynamic provider paths (already done in Phase 2 combined fix)
- [x] P4-T4: Made menu.sh use dynamic script paths (SCRIPT_DIR pattern + all menu option paths)
- [x] P4-T5: Made core/intelligence.sh use dynamic path (SCRIPT_DIR + BASE_DIR pattern)
- [x] P4-T6: Made core/layout.sh use dynamic template paths (SCRIPT_DIR pattern + template path)
- [x] P4-T7: Added XDG_STATE_HOME support to core/workspace.sh

## Files Changed

| File | Action | Lines Changed | Description |
|------|--------|---------------|-------------|
| `scripts/ai/ai.sh` | Modified | +5, -5 | Dynamic BASE_DIR, all tmux path refs converted to `$BASE_DIR/...` |
| `scripts/ai/runtime/ai-runtime.sh` | Modified | +3, -1 | Dynamic BASE_DIR via SCRIPT_DIR pattern |
| `scripts/ai/menu.sh` | Modified | +6, -12 | SCRIPT_DIR pattern, all menu paths converted to `$SCRIPT_DIR/...` |
| `scripts/ai/popup.sh` | Modified | +2, -1 | SCRIPT_DIR pattern for menu.sh invocation |
| `scripts/ai/opencode.sh` | Modified | +2 | SCRIPT_DIR pattern for utils.sh |
| `scripts/ai/gentle.sh` | Modified | +2 | SCRIPT_DIR pattern for utils.sh |
| `scripts/ai/nvim.sh` | Modified | +2 | SCRIPT_DIR pattern for utils.sh |
| `scripts/ai/engram.sh` | Modified | +2 | SCRIPT_DIR pattern for utils.sh |
| `scripts/ai/core/selector.sh` | Modified | +3 | SCRIPT_DIR + BASE_DIR pattern for registry.sh |
| `scripts/ai/core/intelligence.sh` | Modified | +3 | SCRIPT_DIR + BASE_DIR pattern for state.sh |
| `scripts/ai/core/layout.sh` | Modified | +2, -1 | SCRIPT_DIR + BASE_DIR pattern, template path updated |
| `scripts/ai/core/workspace.sh` | Modified | +2 | XDG_STATE_HOME conditional for WORKSPACE_DB |
| `docs/orchestration.md` | Created | +220 | Agent/subagent orchestration framework documentation |

## Verification
- `bats --recursive tests/`: 18/19 passing
- Pre-existing failure: `recovery_url_fix.bats` (old repo URL check) — unrelated to this change

## Notes
- P4-T3 (router.sh) was already complete from Phase 2 combined fix — dynamic BASE_DIR was applied when mistral was added
- tmux command strings in ai.sh required `\$` quoting to prevent variable expansion before inner bash -lc execution
- Dynamic path pattern: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` followed by `BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"` for core scripts

## Delivery
Chained PRs per tasks.md:
- PR 1: Phase 1 + Phase 2 → merged to dev
- PR 2 (this batch): Phase 3 + Phase 4 → target: dev