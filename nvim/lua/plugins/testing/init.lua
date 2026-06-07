-- T3.2 — Neotest + jest + playwright plugin group
--
-- MEAN/MERN test runner integration. The 3 neotest plugins all lazy-load
-- on `event = "BufReadPre *.test.*"` so the test runner is only paid for
-- when a test file is actually opened. Each adapter declares neotest as
-- a dependency so lazy.nvim orders the install correctly.
--
-- Neotest keymap surface lives in nvim/lua/mappings.lua (Phase 3
-- additions: <leader>tn / <leader>tf / <leader>ta).

return {
  {
    "nvim-neotest/neotest",
    event = { "BufReadPre *.test.*", "BufReadPre *.spec.*" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require("neotest").setup({})
    end,
  },

  {
    "nvim-neotest/neotest-jest",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    dependencies = {
      "nvim-neotest/neotest",
    },
    config = function()
      require("neotest-jest").setup({})
    end,
  },

  {
    "thenbe/neotest-playwright",
    dependencies = {
      "nvim-neotest/neotest",
    },
    config = function()
      require("neotest-playwright").setup({})
    end,
  },
}
