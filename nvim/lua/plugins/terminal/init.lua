-- T3.3 — toggleterm.nvim plugin
--
-- Integrated terminal for MEAN/MERN dev (npm scripts, jest watch mode,
-- ng serve, etc.). Lazy-loads on `event = "VeryLazy"` so the terminal
-- only initializes after the editor is fully booted. NvChad v2.5
-- compatible.
--
-- Keymap surface lives in nvim/lua/mappings.lua: <leader>tt.

return {
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })
    end,
  },
}
