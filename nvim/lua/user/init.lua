-- T1.5 / Architecture Decision #4 — Feature-flag chokepoint for plugin loads.
--
-- This module is the single file that gates which optional plugin groups
-- load at boot. Each Phase 2-4 plugin spec uses the pattern:
--
--   {
--     "olimorris/codecompanion.nvim",
--     enabled = function() return require("user").has_ai_keys() end,
--     ...
--   }
--
-- Users without API keys get a clean fallback (tmux-split CLIs only, no
-- in-editor AI loads). Flipping a flag here disables an entire group with
-- zero other file changes.
--
-- Helpers:
--   M.has_ai_keys()  — true if ANY of GEMINI_API_KEY / ANTHROPIC_API_KEY / OPENAI_API_KEY is set
--   M.has_biome()    — true if BIOME_ENABLED=1 (opt-in; default false; large LSP)
--   M.has_octo()     — true if `gh` is on PATH (for octo.nvim GitHub PR/issue integration)

local M = {}

function M.has_ai_keys()
  return vim.env.GEMINI_API_KEY ~= nil
      or vim.env.ANTHROPIC_API_KEY ~= nil
      or vim.env.OPENAI_API_KEY ~= nil
end

function M.has_biome()
  return vim.env.BIOME_ENABLED == "1"
end

function M.has_octo()
  return vim.fn.executable("gh") == 1
end

-- T4.7: Octo.nvim sensible defaults (called from plugins/integrations/init.lua
-- when the plugin loads, gated by has_octo())
function M.apply_octo_defaults()
  vim.g.octo_browse_split_above = 1
  vim.g.octo_view_issue_args = "assignee"
  vim.g.octo_comment_thread_view_as_plain = 0
  vim.g.octo_show_iamaction_prompt = 1
end

return M
