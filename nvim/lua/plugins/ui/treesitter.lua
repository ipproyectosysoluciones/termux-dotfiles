return {
  {
    "nvim-treesitter/nvim-treesitter",

    event = { "BufReadPre", "BufNewFile" },

    build = ":TSUpdate",

    opts = {
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "gitignore",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "regex",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = true,
      },

      incremental_selection = {
        enable = true,

        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },

    config = function(_, opts)
      -- FIX: nvim-treesitter renamed configs.lua → config.lua in recent versions.
      -- The module path changed from nvim-treesitter.configs to nvim-treesitter.config.
      -- See: https://github.com/nvim-treesitter/nvim-treesitter/issues/XXXX
      -- Symptom: "module 'nvim-treesitter.configs' not found" on Neovim startup.
      require("nvim-treesitter.config").setup(opts)
    end,
  },
}
