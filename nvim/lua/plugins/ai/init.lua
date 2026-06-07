-- T2.1 / T2.2 — CodeCompanion.nvim + 4 adapters + fallback chain
--
-- This file is the single source of truth for the in-editor AI surface.
-- The plugin lazy-loads on the first `:CodeCompanion*` invocation; users
-- without API keys get a clean no-op (T1.5 feature flag chokepoint).
--
-- Architecture (per design.md):
--   * cmd-triggered lazy load (no VimEnter / BufRead overhead)
--   * plenary + nvim-treesitter as transitive deps
--   * 4 adapters: gemini, claude, openai-compatible, ollama
--   * on_error fallback chain: gemini → claude → openai → ollama
--   * missing env var → friendly notify, never a stack trace
--
-- Keymap surface lives in nvim/lua/mappings.lua (T2.3-T2.5).

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    -- T1.5 chokepoint: when the user has no API keys set, the spec is
    -- still registered but the in-editor setup becomes a no-op (the
    -- 4 terminal-split keymaps under <leader>g* keep working regardless).
    enabled = function()
      return require("user").has_ai_keys()
    end,
    opts = function()
      local has = function(k)
        local v = vim.env[k]
        return v ~= nil and v ~= ""
      end

      local enabled = function(k)
        if not has(k) then
          vim.notify(
            string.format("[codecompanion] %s not set — adapter disabled", k),
            vim.log.levels.INFO
          )
        end
        return has(k)
      end

      local function on_error(ctx)
        if ctx.status == 429 then
          vim.notify(
            "[codecompanion] rate limit hit, falling back to next adapter",
            vim.log.levels.WARN
          )
          return "fallback"
        end
        vim.notify(
          "[codecompanion] error: " .. (ctx.message or "unknown"),
          vim.log.levels.WARN
        )
        return "halt"
      end

      require("codecompanion").setup({
        adapters = {
          {
            name = "gemini",
            type = "http",
            opts = { api_key = vim.env.GEMINI_API_KEY },
            enabled = enabled("GEMINI_API_KEY"),
          },
          {
            name = "claude",
            type = "http",
            opts = { api_key = vim.env.ANTHROPIC_API_KEY },
            enabled = enabled("ANTHROPIC_API_KEY"),
          },
          {
            name = "openai",
            type = "http",
            opts = {
              api_key = vim.env.OPENAI_API_KEY,
              base_url = vim.env.OPENAI_BASE_URL,
            },
            enabled = enabled("OPENAI_API_KEY"),
          },
          {
            name = "ollama",
            type = "http",
            opts = { base_url = "http://localhost:11434" },
            enabled = true,
          },
        },
        strategies = {
          chat = {
            adapter_priority = { "gemini", "claude", "openai", "ollama" },
            on_error = on_error,
          },
        },
      })
    end,
  },
}
