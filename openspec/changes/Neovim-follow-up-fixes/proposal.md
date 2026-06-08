# Proposal: Neovim-follow-up-fixes

**Change**: `Neovim-follow-up-fixes`
**Author**: gentle-orchestrator
**Created**: 2026-06-08
**Status**: Active

## Summary

Fix 5 deferred tasks from `Neovim-review-update` that were marked as deferred during the chained PR implementation to keep PR sizes manageable. All 5 tasks are low-risk, single-file changes totaling ~42 LOC.

## Motivation

During the `Neovim-review-update` SDD, 5 tasks were explicitly deferred to a follow-up change to maintain PR focus and review bandwidth:

1. **T1.4** — Termux:API clipboard health-check (`options.lua`) — deferred to avoid blocking PR #1 cleanup
2. **T3.6** — DAP Mason registry path for `node-debug2-adapter` — deferred to keep PR #3 MEAN/MERN scope tight
3. **T3.8** — Biome formatter dispatch — deferred to keep PR #3 scope tight
4. **T4.4** — Which-key desc coverage audit — deferred to keep PR #4 VSCode parity scope tight
5. **T4.8** — Lockfile regeneration — deferred to keep PR #4 scope tight (requires SSH to phone-ai)

## Scope

Single PR, single change. All 5 tasks are independent and can ship together.

## Tasks

| # | Task | File | Status |
|---|------|------|--------|
| T1.4 | Clipboard health-check | `nvim/lua/options.lua` | Pending |
| T3.6 | DAP Mason registry | `nvim/lua/plugins/dap/init.lua` | Pending |
| T3.8 | Biome formatter dispatch | `nvim/lua/plugins/formatting/init.lua` | Pending |
| T4.4 | Which-key desc audit | `tests/nvim/nvim_keymaps_desc.bats` | Pending |
| T4.8 | Lockfile regen | `nvim/lazy-lock.json` | Pending |

## Approach

1. T1.4: Add `vim.fn.executable("termux-clipboard-set")` check in `options.lua` before setting clipboard option
2. T3.6: Replace hardcoded `node-debug2-adapter` path with `require("mason-registry").get_package("node-debug2-adapter"):get_install_path()`
3. T3.8: Add `typescript = { "biome" }` to `formatters_by_ft` when `has_biome()` flag is on
4. T4.4: Run `nvim_keymaps_desc.bats` E2E test, fix any missing `desc` fields on `map()` calls
5. T4.8: SSH to phone-ai, run `:Lazy sync`, commit updated `lazy-lock.json`

## Risks

- T4.8 requires SSH to phone-ai (worktree lock may require temp branch workaround)
- T4.4 depends on which-key having `desc` field support (confirmed in NvChad base)

## Dependencies

None — this change only depends on `Neovim-review-update` being archived (which it now is).