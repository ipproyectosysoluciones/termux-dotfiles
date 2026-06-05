return {
  {
    "lewis6991/gitsigns.nvim",

    event = { "BufReadPre", "BufNewFile" },

    config = function()
      require("gitsigns").setup({

        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
        },

        current_line_blame = true,

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- navegación entre cambios
          map("n", "]c", gs.next_hunk)
          map("n", "[c", gs.prev_hunk)

          -- acciones
          map("n", "<leader>hs", gs.stage_hunk)
          map("n", "<leader>hr", gs.reset_hunk)
          map("n", "<leader>hp", gs.preview_hunk)

          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)
        end,
      })
    end,
  },
}
