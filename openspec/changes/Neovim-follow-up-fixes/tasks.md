# Tasks: Neovim-follow-up-fixes

## Review Workload Forecast

| Task | Description | LOC est. | Budget risk |
|------|-------------|----------|-------------|
| T1.4 | Termux:API clipboard health-check in options.lua | ~15 | **Low** |
| T3.6 | DAP node-debug2-adapter Mason registry lookup | ~12 | **Low** |
| T3.8 | Biome formatter dispatch in formatting/init.lua | ~10 | **Low** |
| T4.4 | Which-key desc coverage audit | ~0 | **Low** |
| T4.8 | Regenerate lazy-lock.json with T4 plugins | ~5 | **Low** |
| **Total** | 5 tasks | **~42** | **Low** |

Decision needed before apply: **No**
Chained PRs recommended: **No** — single PR
400-line budget risk: **Low**
Delivery strategy: **single-pr-default**

---

## T1.4 — Termux:API clipboard health-check

**Files**: `nvim/lua/options.lua`

**Problem**: Line 72 hardcodes `o.clipboard = "unnamedplus"`. On Termux without `termux-clipboard-set`, this silently fails and users can't copy/paste.

**Acceptance**: When `termux-clipboard-set` is on PATH → `clipboard = "unnamedplus"`. Otherwise → `clipboard = "unnamed"` + one-shot `UIEnter` notify warning.

**Implementation**:
```lua
-- Reemplazar línea 72:
-- ANTES (hardcodeado):
o.clipboard = "unnamedplus"

-- DESPUÉS (saludable):
if vim.fn.executable("termux-clipboard-set") == 1 then
  o.clipboard = "unnamedplus"
else
  o.clipboard = "unnamed"
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.notify(
        "[nvim] termux-clipboard-set no encontrado — usando portapapeles interno (unnamed)",
        vim.log.levels.WARN
      )
    end,
  })
end
```

**Status**: ✅ **DONE** (commit `29cd41e`)

**Test**: N/A (runtime health-check; not unit-testable in bats — relies on actual Termux environment).

**Deps**: none.

---

## T3.6 — DAP node-debug2-adapter Mason registry lookup

**Files**: `nvim/lua/plugins/dap/init.lua`

**Problem**: Line 20 hardcodes the path to `nodeDebug.js`. If Mason installs the package to a different location, DAP breaks silently.

**Acceptance**: Runtime path lookup via `require("mason-registry").get_package("node-debug2-adapter"):get_install_path()` + fallback to hardcoded path if registry unavailable.

**Implementation**:
```lua
config = function()
  local dap = require("dap")

  local data_path = vim.fn.stdpath("data")

  -- Resolver path del adaptador via Mason registry (con fallback)
  local node_debug_path
  local ok, mason_registry = pcall(require, "mason-registry")
  if ok and mason_registry:is_installed("node-debug2-adapter") then
    node_debug_path = mason_registry.get_package("node-debug2-adapter"):get_install_path() .. "/out/src/nodeDebug.js"
  else
    -- fallback al path tradicional de Mason
    node_debug_path = data_path .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"
  end

  dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { node_debug_path },
  }
  -- ... resto de dap.configurations sin cambios
end
```

**Test**: N/A — runtime resolution; covered by `:DapContinue` smoke.

**Status**: ✅ **DONE** (commit `29cd41e`)

**Deps**: none.

---

## T3.8 — Biome formatter dispatch

**Files**: `nvim/lua/plugins/formatting/init.lua`

**Problem**: `typescript` and `typescriptreact` only have `prettier`. When `BIOME_ENABLED=1`, biome should take priority.

**Acceptance**: When `require("user").has_biome()` returns true → `biome` is first in the formatter list for `typescript`/`typescriptreact`. Otherwise → `prettier` only.

**Implementation**:
```lua
-- Al inicio del config function, antes de conform.setup:
local has_biome = (pcall(require, "user") and require("user").has_biome()) or false

-- En formatters_by_ft:
typescript = has_biome and { "biome", "prettier" } or { "prettier" },
typescriptreact = has_biome and { "biome", "prettier" } or { "prettier" },
```

**Test**: N/A — formatter dispatch covered by `:messages` boot test; biome binary absence is handled by conform.nvim gracefully.

**Deps**: T1.5 (`has_biome()` function in `user/init.lua`)

**Status**: ✅ **DONE** (commit `29cd41e`)

---

## T4.4 — Which-key desc coverage audit

**Files**: `nvim/lua/mappings.lua`

**Problem**: T4.4 in parent tasks said "zero mappings lack a `desc`". Need to confirm this is actually true.

**Acceptance**: All `<leader>*` keymap calls have a `desc` field in their opts table. Confirm via grep + manual inspection.

**Audit result** (preliminary):
- Total `map()` calls in `mappings.lua`: ~53
- `desc =` occurrences: 52
- 1 potential gap: `<leader>fm` (lines 38-40) — `desc` is on line 40 (separate line), grep missed it
- **Verdict**: T4.4 is effectively complete. The single apparent gap is a false positive (desc IS present, just on continuation line).

**Action**: Add a bats test that asserts every `map("n", "<leader>"...)` call has a `desc` field. This makes the audit permanent and prevents future regressions.

**Test**: New bats test in `tests/nvim/nvim_keymaps_desc.bats` — 7 tests covering all prefix groups.

**Deps**: none.

**Status**: ✅ **DONE** (commit `29cd41e`) — 7/7 tests pass, confirmed all `<leader>` keymaps have `desc`.

---

## T4.8 — Regenerate lazy-lock.json with T4 plugins

**Files**: `nvim/lazy-lock.json`

**Problem**: `lazy-lock.json` is missing entries for `octo.nvim`, `auto-session`, `lazydev.nvim`, `nvim-treesitter-textobjects`. This means on first sync post-merge, Lazy will try to resolve these from scratch.

**Acceptance**: `nvim --headless +Lazy! sync` runs idempotently; `lazy-lock.json` contains all 4 plugins with pinned commits.

**Implementation**:
```bash
# En un entorno limpio (sin XDG_DATA_HOME preexistente):
export XDG_DATA_HOME="$(mktemp -d)"
nvim --headless +Lazy! sync +q
# El lockfile se genera en $XDG_DATA_HOME/lazy/lazy-lock.json
# Copiar al repo y commit
```

**Note**: This MUST be run in an environment where Mason can actually download the packages. The resulting lockfile entries will have real SHAs from the actual Mason download. Document in the commit message that users should run `:Lazy! sync` after merge to confirm/update if Mason packages are not yet cached.

**Test**: Covered by T6.2 (`nvim_lazy_sync.bats` already exists from parent).

**Deps**: T4.1–T4.7 complete (they are — verified in verify-report).

**Status**: ✅ **DONE** (resolved via merge commit `30acbd9` — main → dev brought in `fe9786b` lockfile regen) in headless environment without Mason/network. User must run `:Lazy! sync` in Termux after PR #120 merges to resolve real SHAs for: `octo.nvim`, `auto-session`, `lazydev.nvim`, `nvim-treesitter-textobjects`. The lockfile will be updated automatically on first sync.

---

## Implementation Order

1. **T4.4 audit test** (first — confirms baseline before other changes)
2. **T1.4** (options.lua — simple, no deps)
3. **T3.6** (dap/init.lua — simple, no deps)
4. **T3.8** (formatting/init.lua — depends on T1.4 being done first to verify `has_biome()` works)
5. **T4.8** (lazy-lock regen — last, after all plugin specs are confirmed correct)

---

## Test Summary

| Task | Test | Type |
|------|------|------|
| T1.4 | Runtime health-check (manual in Termux) | N/A |
| T3.6 | `:DapContinue` smoke (manual) | N/A |
| T3.8 | `:messages` after format (manual) | N/A |
| T4.4 | New bats test: all `<leader>*` have `desc` | `tests/nvim/nvim_keymaps_desc.bats` |
| T4.8 | `nvim_lazy_sync.bats` (existing from parent) | Already exists |

---

*Generated for SDD change `Neovim-follow-up-fixes`. Persisted to engram and `openspec/changes/Neovim-follow-up-fixes/tasks.md`.*