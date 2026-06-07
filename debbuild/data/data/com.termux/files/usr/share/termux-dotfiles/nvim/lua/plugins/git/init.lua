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

          -- acciones (NvChad v2.5 baseline aliases: hs/hr/hp/hb)
          map("n", "<leader>hs", gs.stage_hunk)
          map("n", "<leader>hr", gs.reset_hunk)
          map("n", "<leader>hp", gs.preview_hunk)

          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)

          -- T4.2: VSCode-style aliases (g* prefix) added on top of the
          -- pre-existing <leader>h* bindings. The two are equivalent —
          -- <leader>gb is the VSCode "git blame" mnemonic, <leader>hb
          -- was the NvChad baseline. Both bind the same gitsigns
          -- actions, so muscle memory from either editor works.
          map("n", "<leader>gb", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>gp", gs.preview_hunk)
          map("n", "<leader>gd", function()
            -- "diff this" — open the diff view for the current hunk
            -- against HEAD. Falls back to no-op if the hunk doesn't
            -- exist (e.g. on an uncommitted, fully-clean line).
            gs.diffthis()
          end)
        end,
      })
    end,
  },
}
