-- T4.1 — pwntester/octo.nvim plugin group
--
-- GitHub PR / issue / review surface for VSCode parity. Loaded lazily
-- on `:Octo` so it only initializes when the user actually opens an
-- issue or PR view. Gated by `require("user").has_octo()` — when `gh`
-- is not on PATH the spec is registered but disabled, so `<leader>o*`
-- keymaps show a friendly notification instead of an E492.
--
-- Why `integrations/` and not `git/`:
--   `git/` holds the lower-level git operations surface (gitsigns,
--   fugitive, diffview, etc.). Octo is a higher-level GitHub-API
--   integration, not a raw git operation — it deserves its own
--   "integrations" group alongside future services (GitLab, Linear,
--   Jira). See design.md "Decision: Plugin spec pattern" rationale.
--
-- Keymap surface lives in nvim/lua/mappings.lua: <leader>op / oi / or.

return {
  {
    "pwntester/octo.nvim",
    cmd = { "Octo" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    -- T1.5 chokepoint: only load when `gh` is on PATH. Users without
    -- gh get a clean no-op and the <leader>o* keymaps fall through
    -- to vim.notify (see mappings.lua).
    enabled = function()
      return require("user").has_octo()
    end,
    config = function()
      -- T4.7: Apply sensible octo.nvim defaults (browse split direction,
      -- issue view args, comment threading, I am action prompt).
      require("user").apply_octo_defaults()
    end,
  },
}
