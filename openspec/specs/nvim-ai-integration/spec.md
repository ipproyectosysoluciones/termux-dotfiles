# nvim-ai-integration Specification

## Purpose

Wire in-editor AI assistance into Neovim via `CodeCompanion.nvim` so the editor matches the AI richness of the existing `scripts/ai/providers/` terminal CLIs. Provide a six-keymap in-editor surface AND four tmux-split keymaps for `gemini`, `claude`, `opencode`, `mistral`. Covers Phase 2.

## Requirements

### Requirement: CodeCompanion Plugin Installation

The system MUST install `olimorris/codecompanion.nvim` via a lazy.nvim spec in `nvim/lua/plugins/ai/init.lua` (currently empty) and MUST declare the commit in `lazy-lock.json`. The plugin MUST lazy-load on the first `:CodeCompanion*` invocation.

#### Scenario: CodeCompanion loads on demand

- GIVEN the spec exists
- WHEN `:Lazy sync` runs and `nvim --headless +q` exits cleanly
- THEN `:lua require("codecompanion")` MUST NOT error
- AND `lazy-lock.json` MUST contain a `codecompanion.nvim` commit
- AND `nvim --startuptime /tmp/startup.log +q` MUST show no CodeCompanion modules in early `UiEnter`

### Requirement: AI Adapter Configuration

The system MUST configure four adapters (Gemini, Claude, OpenAI-compatible, Ollama). Copilot MAY be a fifth, gated by `require("user").has_copilot()`. Each adapter MUST read its key from a documented env var and MUST surface a friendly error (not a stack trace) when missing.

#### Scenario: Adapters selectable + Ollama offline

- GIVEN `GEMINI_API_KEY` is set
- WHEN `:CodeCompanionChat` opens the picker
- THEN Gemini SHALL be listed and a test prompt SHALL succeed
- AND the Ollama adapter SHALL send requests to `http://localhost:11434` with no external key

#### Scenario: Missing key shows friendly error

- GIVEN `GEMINI_API_KEY` is unset
- WHEN `:CodeCompanionChat` invokes Gemini
- THEN a message naming `GEMINI_API_KEY` SHALL appear
- AND Neovim MUST NOT crash

### Requirement: In-Editor AI Keymaps

The system MUST map the six previously-dead CodeCompanion keymaps in `nvim/lua/mappings.lua` to live `:CodeCompanion*` commands: `<leader>aa` (chat, normal+visual), `<leader>ai` (inline), `<leader>at` (toggle), `<leader>am` (actions), `<leader>as` (switch adapter). None SHALL produce E492.

#### Scenario: All six keymaps resolve

- WHEN `<leader>aa` is pressed in normal mode, the chat buffer MUST open and `:messages` MUST NOT contain E492
- WHEN a 3-line visual selection is active and `<leader>ai` is pressed, the selection SHALL be sent as inline-edit context
- WHEN an adapter is selected via `<leader>as`, the active adapter indicator MUST update and subsequent `<leader>aa` calls SHALL use the new adapter

### Requirement: Terminal-Split AI Keymaps

The system MUST add four keymaps spawning the existing `scripts/ai/providers/{gemini,claude,opencode,mistral}.sh` CLIs in tmux splits: `<leader>ag` → gemini, `<leader>ac` → claude, `<leader>ao` → opencode, `<leader>am` → mistral. The `am` collision with CodeCompanion actions SHALL be resolved in Phase 4.

#### Scenario: <leader>ag opens gemini split

- GIVEN `gemini.sh` is executable and the user is in tmux
- WHEN `<leader>ag` is pressed
- THEN a horizontal tmux split MUST open
- AND `gemini.sh` SHALL execute inside
- AND if the `gemini` binary is missing, the split MUST show `command not found` and Neovim MUST NOT crash

### Requirement: AI Fallback Chain

The system MUST retry with the next adapter when the active one returns HTTP 429 or a transient error. Default chain: Gemini → Claude → OpenAI → Ollama. The chain MUST be configurable in `lua/plugins/ai/init.lua`.

#### Scenario: Rate limit triggers fallback

- GIVEN the chain is `gemini → claude → openai → ollama`
- WHEN Gemini returns HTTP 429
- THEN CodeCompanion SHALL retry with Claude
- AND a status message SHALL indicate the fallback

### Requirement: MCP Server Hooks (Optional)

The system MAY integrate MCP servers into CodeCompanion, reading the server list from `scripts/ai/core/`. When MCP is absent, this SHALL be a no-op.

#### Scenario: MCP server registered when configured

- GIVEN an MCP server is configured and the client is enabled
- WHEN `:CodeCompanion` is invoked
- THEN the registered tools SHALL be available in the chat UI

### Requirement: API Key Documentation

The system MUST document the env-var contract in `docs/nvim-ai.md` (see `nvim-documentation` spec) with one row per adapter.

#### Scenario: docs/nvim-ai.md covers all adapters

- WHEN a reader searches "API key"
- THEN a table MUST list Gemini, Claude, OpenAI, Ollama with env vars and setup snippets
