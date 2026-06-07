-- T3.5 — vim-dadbod + vim-dadbod-ui plugin group
--
-- Database client for MEAN/MERN dev. The core plugin (vim-dadbod)
-- registers a connection protocol and parser; the UI plugin adds the
-- sidebar + buffer picker.
--
-- Supported URL schemes: mongodb://, postgresql://, mysql://,
-- sqlite://, redis://, etc. (See vim-dadbod docs.)
--
-- Keymap surface lives in nvim/lua/mappings.lua: <leader>db.

return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
    },
    config = function()
      -- vim-dadbod has no setup() function; the core plugin auto-registers
      -- on first :DB call. vim-dadbod-ui's setup() is called via its
      -- own spec block below.
    end,
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    config = function()
      require("dadbod-ui").setup({
        -- Highlight the connection string under the cursor when in a
        -- URL buffer; default UI on the right side; auto-disconnect
        -- when the buffer is closed.
        components = {
          { name = "databases" },
          { name = "tables" },
          { name = "columns" },
          { name = "preview" },
        },
        auto_disconnect = true,
        search_titles = true,
      })
    end,
  },
}
