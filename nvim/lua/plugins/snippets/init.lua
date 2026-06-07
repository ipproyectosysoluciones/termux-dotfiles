-- T3.6 — Per-stack VSCode-format snippet packs
--
-- Loads the project's nvim/snippets/ directory via the official
-- `luasnip.loaders.from_vscode` loader. This integrates with the
-- existing friendly-snippets (base pack) and adds MEAN/MERN-tailored
-- snippets (React, Angular, Express, Mongoose) under per-stack dirs.
--
-- The package.json manifest in nvim/snippets/ enumerates the packs
-- so the loader picks them up by name. New packs can be added by
-- dropping a *.json file in the matching subdir.
--
-- Keymap surface is provided by LuaSnip itself (no custom mapping
-- needed — <Tab>/<C-j> expansions work as long as LuaSnip is loaded).

return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
    },
    config = function(_, opts)
      require("luasnip").config.set_config(opts)
      -- T3.6: lazy-load the per-stack VSCode-format packs at the
      -- project's nvim/snippets/ path. friendly-snippets provides the
      -- base language snippets (html, css, js, etc.) so we only need
      -- the stack-specific ones here.
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { "nvim/snippets" },
      })
    end,
  },
}
