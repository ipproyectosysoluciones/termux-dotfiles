# Design: Neovim-review-update

## Technical Approach

Consolidate `nvim/lua/plugins/*` as the single source of truth, delete the dead `lua/configs/*` tree (with 48h soak), and incrementally layer in **CodeCompanion.nvim** + four tmux-split AI keymaps (Phase 2), **MEAN/MERN tooling** (Phase 3), **VSCode-parity plugins** (Phase 4), **bilingual docs** (Phase 5), and **bats integration tests** (Phase 6). NvChad v2.5 stays pinned; `lazy.nvim` remains the plugin manager; all new plugins land as inline `config = function()` blocks inside `lua/plugins/<group>/init.lua` — never the dead `lua/configs/*` path. CodeCompanion loads lazily on first `:CodeCompanion*` invocation; tmux splits use `vim.fn.termopen` reusing the existing `scripts/ai/providers/*.sh` CLIs. The AI fallback chain (Gemini → Claude → OpenAI → Ollama) mirrors the pattern already in `scripts/ai/providers/gemini.sh` (the QUOTA_EXHAUSTED → opencode branch). Two keymap collisions are resolved by a coherent prefix scheme: `<leader>a*` (CodeCompanion) vs `<leader>g*` (AI terminal splits), and `<leader>e` (nvim-tree) vs `<leader>de` (diagnostic float).

## Architecture Decisions

### Decision: Plugin spec pattern

**Choice**: All new plugins are declared inline in `nvim/lua/plugins/<group>/init.lua` with `config = function() ... end`; nothing under `lua/configs/`.
**Alternatives**: (a) Restore the dead `lua/configs/*` pattern; (b) introduce a third `lua/ai-plugins/` tree.
**Rationale**: The active `plugins/*/init.lua` tree is already wired into `init.lua` via `{ import = "plugins" }` and the `lazy.nvim` runtime executes the `config` function on demand. Adding to `configs/*` would require a new `require` chain and reproduce the dead-code problem we are deleting. Single tree = single source of truth.

### Decision: AI keymap prefix scheme

**Choice**: `<leader>a*` stays for CodeCompanion in-editor (5 keys: `aa/ai/at/am/as`); `<leader>g*` for tmux-split AI CLIs (4 keys: `gg/ga/gc/go` for gemini/gemini-CLI? — see table). Mistral moves from collision slot `<leader>am` to `<leader>gm`.
**Alternatives**: (a) co-opt `<leader>a*` for both (overloads `am`); (b) `<leader>x*` for terminals (unused but unfamiliar).
**Rationale**: `<leader>g*` mirrors the `scripts/ai/providers/gemini.sh` mnemonic and isolates CodeCompanion's six actions from the four CLI-spawn actions. No `<leader>a*` key collides with `<leader>g*`; the prefix group `g*` is currently unused.

### Decision: nvim-tree / diagnostic-float collision

**Choice**: `<leader>e` → `nvim-tree` toggle (Phase 3, primary owner: VSCode parity). Diagnostic float moves to `<leader>de` ("diagnostic-eval").
**Alternatives**: (a) keep `<leader>e` for diagnostic float, pick a different key for nvim-tree (loses the VSCode parity); (b) gate nvim-tree behind `<leader>E` (uppercase).
**Rationale**: nvim-tree is invoked 5–10x more often than the diagnostic float. The `<leader>d*` prefix is already a diagnostic group (`[d`, `]d`, `<leader>q`) — `<leader>de` fits cleanly. `<leader>q` (diagnostic loclist) is kept.

### Decision: AI terminal-split mechanism

**Choice**: `vim.fn.termopen("bash $DOTFILES/scripts/ai/providers/<provider>.sh", { env = {...} })`, opened in a horizontal split. The split is created first with `vim.cmd("split")`, then `termopen` writes into the new buffer; the existing `scripts/ai/providers/*.sh` CLIs are reused unchanged.
**Alternatives**: (a) `vim.cmd("terminal")` + `vim.api.nvim_chan_send` (less control over env); (b) shell out to `tmux split-window` (requires `tmux` running — false negative on bare terminals).
**Rationale**: `termopen` returns a `job_id` we can attach `<CR>` to send the initial prompt; no tmux dependency. The CLIs already accept env-var-driven config (`$GEMINI_WORKSPACE`, `$CLAUDE_PROJECT`, etc.) so no provider scripts are modified.

### Decision: Bilingual doc lint

**Choice**: A bats test (`tests/nvim/nvim_docs_i18n.bats`) greps every user-facing doc under `docs/nvim-*.md`, `docs/neovim.md`, and `nvim/README.md` and asserts each contains `^## ES` and `^## EN` (anchored, on their own line).
**Alternatives**: (a) manual review per PR; (b) markdownlint custom rule (heavyweight).
**Rationale**: Plain grep is fast, has zero deps, and the bats harness already runs in CI via `bats --recursive tests/`. The convention is simple enough to lint mechanically.

## Keymap Scheme (FINAL)

| Key | Mode | Phase | Owner | Action |
|---|---|---|---|---|
| `<leader>aa` | n/v | 2 | CodeCompanion | `CodeCompanionChat` |
| `<leader>ai` | n/v | 2 | CodeCompanion | `CodeCompanion` (inline) |
| `<leader>at` | n | 2 | CodeCompanion | `CodeCompanionChat -t` (toggle) |
| `<leader>am` | n | 2 | CodeCompanion | `CodeCompanionActions` |
| `<leader>as` | n | 2 | CodeCompanion | `CodeCompanionChat -s` (switch adapter) |
| `<leader>ag` | n | 2 | tmux split | gemini CLI |
| `<leader>ac` | n | 2 | tmux split | claude CLI |
| `<leader>ao` | n | 2 | tmux split | opencode CLI |
| `<leader>gm` | n | 2 | tmux split | mistral CLI (resolution of `am` collision) |
| `<leader>gg` | n | 2 | tmux split | gentle CLI (Phase 6 — provider parity) |
| `<leader>fm` | n | 1 | conform | format buffer (existing) |
| `<leader>ff` | n | 1 | telescope | find_files (existing) |
| `<leader>fg` | n | 1 | telescope | live_grep (existing) |
| `<leader>fb` | n | 1 | telescope | buffers (existing) |
| `<leader>fh` | n | 1 | telescope | help_tags (existing) |
| `<leader>tt` | n | 3 | toggleterm | toggle terminal |
| `<leader>e` | n | 3 | nvim-tree | toggle file tree (resolution of `e` collision) |
| `<leader>de` | n | 3 | diagnostic | open float (moved from `<leader>e`) |
| `<leader>tn` | n | 3 | neotest | run nearest test |
| `<leader>tf` | n | 3 | neotest | run file's tests |
| `<leader>ta` | n | 3 | neotest | run all tests |
| `<leader>db` | n | 3 | vim-dadbod | open DB UI |
| `<leader>hp` | n | 4 | gitsigns | preview hunk (existing) |
| `<leader>hb` | n | 4 | gitsigns | blame line full (existing) |
| `<leader>hs` | n | 4 | gitsigns | stage hunk (existing) |
| `<leader>hr` | n | 4 | gitsigns | reset hunk (existing) |
| `<leader>o` | n | 4 | octo | issue list (Phase 4) |
| `<leader>rn` | n | 1 | LSP | rename (existing) |
| `<leader>ca` | n | 1 | LSP | code action (existing) |
| `<leader>y` | n | 1 | yank | yank file (existing) |
| `<leader>sr` | n | 1 | utility | source MYVIMRC (existing) |
| `<leader>ch` | n | 1 | utility | clear hlsearch (existing) |
| `<leader>tw` | n | 1 | utility | toggle wrap (existing) |

Total live `<leader>*` mappings: 33. Zero collisions remain.

## Data Flow

### CodeCompanion request path

```
User in buffer
  │  <leader>aa
  ▼
nvim/lua/mappings.lua (lazy-loaded via <leader>aa → :CodeCompanionChat)
  │  triggers CodeCompanion
  ▼
nvim/lua/plugins/ai/init.lua (lazy spec: cmd = { "CodeCompanion" })
  │  loads on first invocation
  ▼
adapters = { gemini, claude, openai, ollama }
  │  reads env: GEMINI_API_KEY, ANTHROPIC_API_KEY, OPENAI_API_KEY
  ▼
HTTP request → provider API → response → chat buffer
  │
  ├─ on HTTP 429: fallback chain to next adapter
  └─ on no env var: friendly "GEMINI_API_KEY not set" msg, no crash
```

### tmux-split AI request path

```
User in buffer
  │  <leader>ag (or ac, ao, gm)
  ▼
nvim/lua/mappings.lua → vim.cmd("split") | vim.fn.termopen(...)
  │
  ▼
new horizontal split (no tmux dep)
  │  env: GEMINI_WORKSPACE=$PWD, AI_PROJECT, AI_AGENT, AI_SKILL
  ▼
bash $DOTFILES/scripts/ai/providers/gemini.sh (unchanged)
  │  spawns `gemini --yolo --prompt ...`
  │  on QUOTA_EXHAUSTED: falls back to opencode (existing)
  └─ on missing binary: prints to terminal, nvim unharmed
```

## File Changes

| File | Action | Phase | Description |
|---|---|---|---|
| `nvim/lua/configs/lspconfig.lua` | **Delete** (after 48h soak in `_legacy_$(date)/`) | 1 | Dead |
| `nvim/lua/configs/cmp.lua` | **Delete** | 1 | Dead — active path is `plugins/completion/init.lua` |
| `nvim/lua/configs/conform.lua` | **Delete** | 1 | Dead — active path is `plugins/formatting/init.lua` |
| `nvim/lua/configs/snippets.lua` | **Delete** | 1 | Dead — 75 HTML snippets lost; replaced by `friendly-snippets` + per-stack packs (Phase 3) |
| `nvim/lua/configs/ui.lua` | **Delete** | 1 | Dead — NvChad provides these defaults |
| `nvim/lua/configs/formatters/custom.lua` | **Delete** | 1 | Dead — empty stub |
| `nvim/lua/configs/servers/{ts_ls,cssls,html,eslint,tailwindcss}.lua` | **Delete** | 1 | Dead — 5 server files, never loaded |
| `nvim/lua/mappings.lua` | **Modify** | 1, 2, 3, 4 | Phase 1: delete 10 dead keymaps. Phase 2: add `<leader>ag/ac/ao/gm` (4 tmux splits). Phase 3: add `<leader>tt/e/de/tn/tf/ta/db` (7 keys). Phase 4: add `<leader>o` (octo). |
| `nvim/lua/options.lua` | **Modify** | 1 | Add Termux:API presence detection → fallback `o.clipboard = "unnamedplus"` to `"unnamed"` when `which termux-clipboard-set` is empty. |
| `nvim/lua/plugins/ai/init.lua` | **Modify** | 2 | Populate with CodeCompanion spec (lazy `cmd = { "CodeCompanion" }`) + 4 adapters + fallback chain. |
| `nvim/lua/plugins/terminal/init.lua` | **Modify** | 3 | Add `toggleterm.nvim` (event = `VeryLazy`). |
| `nvim/lua/plugins/testing/init.lua` | **Modify** | 3 | Add `neotest` + `neotest-jest` + `thenbe/neotest-playwright` (event = `BufReadPre *.test.*`). |
| `nvim/lua/plugins/ui/init.lua` | **Modify** | 3 | Add `nvim-tree/nvim-tree.lua` spec (event = `VimEnter`, gated by `nvim-tree in lock` check). |
| `nvim/lua/plugins/dap/init.lua` | **Modify** | 3 | Add `node-debug2-adapter` to Mason `ensure_installed`; replace hardcoded `vim.fn.stdpath` path with `require("mason-registry").get_package("node-debug2-adapter"):get_install_path()`. |
| `nvim/lua/plugins/lsp/init.lua` | **Modify** | 3 | Add `angularls` (required) and `biome` (gated by `require("user").has_biome()` — default false) to `ensure_installed`. |
| `nvim/lua/plugins/git/init.lua` | **Modify** | 4 | Add `octo.nvim` spec (cmd-triggered); enhance gitsigns `current_line_blame_opts`. |
| `nvim/lua/plugins/editor/init.lua` | **Modify** | 4 | Add `auto-session` (event = `VimEnter`); add `nvim-treesitter/nvim-treesitter-textobjects`; add `nvim-treesitter/nvim-treesitter` (already in lock). |
| `nvim/lua/plugins/completion/init.lua` | **Modify** | 4 | Add `lazydev.nvim` dep; add `refactoring.nvim` (cmd-triggered). |
| `nvim/lua/plugins/formatting/init.lua` | **Modify** | 3 | Extend `formatters_by_ft` with `typescript = { "biome" }` when biome feature flag is on. |
| `nvim/lua/user/init.lua` | **Create** | 1 | New `M.has_ai_keys()`, `M.has_biome()`, `M.has_octo()` helpers (env-var checks). Required by the `enabled = function() ... end` pattern. |
| `nvim/snippets/{package.json, react/, angular/, express/, mongoose/}` | **Create** | 3 | VSCode-format `.json` snippet packs loaded via `require("luasnip.loaders.from_vscode").lazy_load({ paths = { "nvim/snippets" } })`. |
| `nvim/lazy-lock.json` | **Modify** | 2, 3, 4 | Regenerate as new plugins land (`vim.fn.system("nvim +Lazy sync")`). |
| `scripts/nvim/plugins.sh` | **Rename** | 1 | → `scripts/nvim/zsh-plugins.sh`. Pure rename + content update header comment. |
| `docs/neovim.md` | **Rewrite** | 5 | Bilingual ES+EN, real paths, 33-plugin table, full keymap table. |
| `nvim/README.md` | **Expand** | 1, 5 | Phase 1: ≥50 lines (prereqs, `:Lazy sync`, `:MasonInstall`, LSP smoke). Phase 5: bilingual. |
| `docs/nvim-ai.md` | **Create** | 5 | Bilingual; adapter env-var table; keymap cheatsheet for both in-editor and tmux-split; fallback chain diagram; feature flag. |
| `docs/nvim-mean-mern.md` | **Create** | 5 | Bilingual; per-stack (MEAN/MERN) sections: LSPs, snippets, DAP, formatter; Termux disk warning. |
| `docs/nvim-troubleshooting.md` | **Create** | 5 | Bilingual; symptom→cause→fix entries: E492, Termux /tmp, Mason downloads, DAP path, clipboard, Telescope 0.1.x. |
| `docs/nvim-keymaps.md` | **Create** | 5 | Single-page cheatsheet grouped by prefix; single-language (EN) is acceptable per spec. |
| `docs/i18n.md` | **Create** | 5 | Bilingual convention: `## ES` / `## EN` dividers, ES-first order, code blocks stay EN. |
| `tests/nvim/nvim_boot.bats` | **Create** | 6 | `nvim --headless +q` exits 0, `:messages` empty. |
| `tests/nvim/nvim_keymaps.bats` | **Create** | 6 | All 33 documented keymaps resolve; no E492. |
| `tests/nvim/nvim_lazy_sync.bats` | **Create** | 6 | `:Lazy sync` doesn't crash; `lazy-lock.json` regenerates. |
| `tests/nvim/nvim_lsp_install.bats` | **Create** | 6 | `:MasonInstall` smoke; `skip` if no network. |
| `tests/nvim/nvim_docs_i18n.bats` | **Create** | 6 | Every user-facing doc has `^## ES` and `^## EN`. |
| `Formula/termux-dotfiles.rb` | **No change** | — | Symlink logic is path-agnostic; new docs are picked up by `prefix.install Dir["*"]`. |

## Interfaces / Contracts

### CodeCompanion adapter fallback (Phase 2)

```lua
-- nvim/lua/plugins/ai/init.lua (excerpt)
return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = function()
      local has = function(k) return vim.env[k] ~= nil and vim.env[k] ~= "" end
      require("codecompanion").setup({
        adapters = {
          { name = "gemini",  type = "http", opts = { api_key = vim.env.GEMINI_API_KEY }, enabled = has("GEMINI_API_KEY") },
          { name = "claude",  type = "http", opts = { api_key = vim.env.ANTHROPIC_API_KEY }, enabled = has("ANTHROPIC_API_KEY") },
          { name = "openai",  type = "http", opts = { api_key = vim.env.OPENAI_API_KEY, base_url = vim.env.OPENAI_BASE_URL }, enabled = has("OPENAI_API_KEY") },
          { name = "ollama",  type = "http", opts = { base_url = "http://localhost:11434" }, enabled = true },
        },
        strategies = {
          chat = {
            adapter_priority = { "gemini", "claude", "openai", "ollama" },
            on_error = function(ctx)
              if ctx.status == 429 then return "fallback" end
              vim.notify("AI error: " .. (ctx.message or "unknown"), vim.log.levels.WARN)
              return "halt"
            end,
          },
        },
      })
    end,
  },
}
```

### tmux-split keymap pattern (Phase 2)

```lua
-- nvim/lua/mappings.lua (excerpt added in Phase 2)
local function ai_split(provider, script)
  return function()
    local dotfiles = vim.env.DOTFILES or (vim.fn.stdpath("config") .. "/../../dotfiles")
    vim.cmd("split")                          -- horizontal split, no tmux dep
    local job = vim.fn.termopen({
      "bash", vim.fn.fnamemodify(script, ":p"),
    }, {
      env = vim.tbl_extend("force", vim.fn.environ(), {
        AI_WORKSPACE = vim.fn.getcwd(),
        AI_PROJECT   = vim.env.AI_PROJECT   or "default",
        AI_AGENT     = vim.env.AI_AGENT     or "generic-agent",
        AI_SKILL     = vim.env.AI_SKILL     or "generic-skill",
      }),
    })
    if job == 0 then
      vim.notify(provider .. " CLI missing — split opened but shell returned 0", vim.log.levels.WARN)
    end
  end
end

local DOT = vim.env.DOTFILES or vim.fn.expand("~/dotfiles")
map("n", "<leader>ag", ai_split("gemini",   DOT .. "/scripts/ai/providers/gemini.sh"),   { desc = "AI: gemini CLI"   })
map("n", "<leader>ac", ai_split("claude",   DOT .. "/scripts/ai/providers/claude.sh"),   { desc = "AI: claude CLI"   })
map("n", "<leader>ao", ai_split("opencode", DOT .. "/scripts/ai/providers/opencode.sh"), { desc = "AI: opencode CLI" })
map("n", "<leader>gm", ai_split("mistral",  DOT .. "/scripts/ai/providers/mistral.sh"),  { desc = "AI: mistral CLI"  })
```

### Termux:API clipboard health-check (Phase 1)

```lua
-- nvim/lua/options.lua (appended; preserves existing /tmp shim above)
local has_termux_api = vim.fn.executable("termux-clipboard-set") == 1
                       or vim.fn.executable("termux-clipboard-get") == 1
vim.opt.clipboard = has_termux_api and "unnamedplus" or "unnamed"
if not has_termux_api then
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.notify("Termux:API not detected — using unnamed register for clipboard", vim.log.levels.INFO)
    end,
  })
end
```

### Bilingual doc lint (Phase 6)

```bash
# tests/nvim/nvim_docs_i18n.bats
@test "every user-facing doc has ## ES and ## EN sections" {
  local docs=(
    "$PROJECT_ROOT/docs/neovim.md"
    "$PROJECT_ROOT/docs/nvim-ai.md"
    "$PROJECT_ROOT/docs/nvim-mean-mern.md"
    "$PROJECT_ROOT/docs/nvim-troubleshooting.md"
    "$PROJECT_ROOT/docs/i18n.md"
    "$PROJECT_ROOT/nvim/README.md"
  )
  for f in "${docs[@]}"; do
    [[ -f "$f" ]] || { skip "$f not yet written (Phase 5)"; continue; }
    grep -Eq '^## ES$' "$f" || { echo "missing ## ES in $f"; return 1; }
    grep -Eq '^## EN$' "$f" || { echo "missing ## EN in $f"; return 1; }
  done
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Smoke | `nvim --headless +q` exits 0; no E5108/E5113 in `:messages` | `tests/nvim/nvim_boot.bats` |
| Plugin manager | `:Lazy sync` runs; `lazy-lock.json` regenerates | `tests/nvim/nvim_lazy_sync.bats` |
| Keymap audit | All 33 documented `<leader>*` keymaps resolve to live commands (no E492) | `tests/nvim/nvim_keymaps.bats` (uses `nvim --headless -c "execute 'normal <leader>xx'" -c "messages" -c "q"`) |
| LSP install | `:MasonInstall` runs the install list; `skip` if no network (`nc -z 8.8.8.8 53`) | `tests/nvim/nvim_lsp_install.bats` |
| Doc convention | Every user-facing doc has `^## ES` and `^## EN` anchored headings | `tests/nvim/nvim_docs_i18n.bats` |

All bats tests live under `tests/nvim/`, load `tests/test_helper.bash`, and are picked up by the existing `bats --recursive tests/` CI runner. The DAP path-resolution test and the tmux-split keymap test are deferred to a follow-up change (out of scope here per spec — would need a real `$GEMINI_API_KEY` to assert on the chain).

## Migration / Rollout

### Phase 1 soak pattern (48h)

- **Day 0**: `git mv` the 11 dead `lua/configs/*` files into `nvim/lua/configs/_legacy_$(date +%Y%m%d)/`. Do NOT `git rm` yet.
- **Day 0–2 (soak window)**: ship PR #1 with the dead files in `_legacy_$(date)/`. CI + `nvim --headless +q` must pass. Anyone on a long-running session can `diff -ru configs/_legacy configs/` and confirm nothing changed.
- **Day 2**: follow-up commit in the same PR (or a tiny one-liner PR) `git rm -r` the `_legacy_$(date)/` directory. PR #1 lands clean.
- **Per-PR**: each chained PR targets `main`. Revert via `gh pr revert <N>` or `git revert <merge-sha>`. The 6 PRs are independently revertable.

### Feature-flag rollback (Phases 2–4)

- New plugin specs are gated by `enabled = function() return require("user").has_ai_keys() end` (default true). Users without API keys fall back to tmux-split CLIs only — no in-editor AI loads.
- `nvim/lua/user/init.lua` is the single chokepoint; flipping a flag here disables an entire plugin group at boot, no other file changes needed.

## Open Questions

None — all locked decisions and deferred questions are resolved in the proposal/spec phases. The two keymap collisions have final resolutions documented above.

## Delivery Strategy

`auto-chain`, `stacked-to-main`. 6 chained PRs as in the proposal's PR Plan table. Per-PR budget 80–280 LOC code, all under the 400-line review budget.
