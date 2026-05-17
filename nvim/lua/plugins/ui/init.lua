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
}
