-- T3.4 — Enable nvim-tree (was in lock but not loaded) + dashboard
--
-- The nvim-tree plugin is already in lazy-lock.json from NvChad v2.5
-- baseline; it just was never wired into a plugin spec. Activating it
-- here:
--   - event = "VimEnter" so it only initializes after UI is ready
--   - filter node_modules / .git / build artifacts from the tree
--   - respect .gitignore
--
-- T4.4 — which-key.nvim additions live in the third spec block. We
-- extend the file (not replace it) so all T3.4 work is preserved.
--
-- Keymap surface lives in nvim/lua/mappings.lua: <leader>e.

return {
  {
    "nvimdev/dashboard-nvim",

    event = "VimEnter",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      require("dashboard").setup({
        theme = "hyper",

        config = {
          header = {
            "NVIM DEV ENV",
            "----------------",
          },

          shortcut = {
            {
              desc = "Find File",
              group = "Label",
              action = "Telescope find_files",
              key = "f",
            },
            {
              desc = "Recent Files",
              group = "Label",
              action = "Telescope oldfiles",
              key = "r",
            },
            {
              desc = "Config",
              group = "Label",
              action = "e ~/.config/nvim",
              key = "c",
            },
          },
        },
      })
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },
        view = {
          width = 30,
          hide_root_folder = false,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
          float = {
            enable = false,
            quit_on_focus_loss = true,
            open_on_config_dir = false,
          },
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = "name",
          root_markers = { "init.lua", ".git", ".hg", ".svn" },
          indent_markers = { "├──", "└──" },
          icons = {
            webdev_colors = true,
            git_placement = "before",
            modified_placement = "signcolumn",
            bookmark_placement = "signcolumn",
          },
        },
        filters = {
          dotfiles = false,
          custom = {
            { pattern = "\\.git$", exclude = false },
            { pattern = "node_modules", exclude = true },
            { pattern = "dist", exclude = true },
            { pattern = "build", exclude = true },
            { pattern = "target", exclude = true },
          },
        },
        git = {
          enable = true,
          ignore = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            preview = false,
            resize_window = true,
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "lazy", "qf", "diff" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
        },
      })
    end,
  },

  {
    -- T4.4 — folke/which-key.nvim: VSCode-style popup that shows
    -- available keymaps as the user types the prefix. This is the
    -- "discoverability" plugin that lets users learn the 33 live
    -- <leader>* mappings without grep'ing mappings.lua.
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      -- which-key needs a longer timeoutlen than the vim default
      -- (1000ms) so the popup stays open while the user mulls over
      -- the next key. 500ms is the documented sweet spot from the
      -- which-key README.
      vim.opt.timeoutlen = 500

      local ok, wk = pcall(require, "which-key")
      if not ok then
        vim.notify(
          "[which-key] require failed — keymap hints disabled",
          vim.log.levels.WARN
        )
        return
      end

      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
        icons = {
          mappings = vim.g.have_nerd_font and {} or {
            Mappings = "",
            User = "",
            Terminal = "",
          },
          keys = {
            Up = "<Up> ",
            Down = "<Down> ",
            Left = "<Left> ",
            Right = "<Right> ",
            C = "<C-…> ",
            M = "<M-…> ",
            D = "<D-…> ",
            S = "<S-…> ",
            CR = "<CR> ",
            Esc = "<Esc> ",
            ScrollWheelDown = "<ScrollWheelDown> ",
            ScrollWheelUp = "<ScrollWheelUp> ",
            NL = "<NL> ",
            BS = "<BS> ",
            Space = "<Space> ",
            Tab = "<Tab> ",
            F1 = "<F1>",
            F2 = "<F2>",
            F3 = "<F3>",
            F4 = "<F4>",
            F5 = "<F5>",
            F6 = "<F6>",
            F7 = "<F7>",
            F8 = "<F8>",
            F9 = "<F9>",
            F10 = "<F10>",
            F11 = "<F11>",
            F12 = "<F12>",
          },
        },
      })

      -- T4.4: <leader> group labels. These are the labels which-key
      -- shows in the popup, grouped by prefix per the design.md
      -- keymap scheme. They MUST stay in sync with the actual
      -- bindings in nvim/lua/mappings.lua (the bats tests in
      -- vscode_parity_plugins.bats and devtools_keymaps.bats enforce
      -- the desc field on every map() call).
      wk.add({
        { "<leader>a", group = "AI" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>d", group = "Diagnostic" },
        { "<leader>e", group = "Explorer" },
        { "<leader>f", group = "Find / Format" },
        { "<leader>g", group = "AI (terminal)" },
        { "<leader>h", group = "Hunk (gitsigns)" },
        { "<leader>o", group = "Octo / Integrations" },
        { "<leader>s", group = "Split / Session" },
        { "<leader>t", group = "Tool / Test" },
        { "<leader>q", group = "Quickfix" },
      })
    end,
  },
}
