return {

  -- =====================================
  -- Telescope
  -- =====================================

  {
    "nvim-telescope/telescope.nvim",

    cmd = "Telescope",

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
    },
  },

  -- =====================================
  -- Which Key
  -- =====================================

  {
    "folke/which-key.nvim",

    event = "VeryLazy",

    opts = {},
  },

  -- =====================================
  -- Bufferline
  -- =====================================

  {
    "akinsho/bufferline.nvim",

    version = "*",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- =====================================
  -- Indent Guides
  -- =====================================

  {
    "lukas-reineke/indent-blankline.nvim",

    main = "ibl",

    opts = {},
  },

  -- =====================================
  -- Better UI Messages
  -- =====================================

  {
    "folke/noice.nvim",

    event = "VeryLazy",

    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    opts = {},
  },

}
