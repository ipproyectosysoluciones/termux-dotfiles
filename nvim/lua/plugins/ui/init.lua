-- T3.4 — Enable nvim-tree (was in lock but not loaded) + dashboard
--
-- The nvim-tree plugin is already in lazy-lock.json from NvChad v2.5
-- baseline; it just was never wired into a plugin spec. Activating it
-- here:
--   - event = "VimEnter" so it only initializes after UI is ready
--   - filter node_modules / .git / build artifacts from the tree
--   - respect .gitignore
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
}
