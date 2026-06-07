return {

  {
    "williamboman/mason.nvim",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- T3.1 — MEAN/MERN LSP augmentation. `angularls` is required for
      -- Angular templates; `biome` is opt-in (default off) so users on
      -- tight Termux disk budgets can defer the ~500MB Angular install.
      -- `install_lsp_on_demand = true` mitigates Termux disk pressure:
      -- only the LSPs the user actually opens a file for will be fetched.
      ensure_installed = {
        "bashls",
        "cssls",
        "html",
        "jsonls",
        "lua_ls",
        "ts_ls",
        "eslint",
        "angularls",
        -- biome is conditionally appended in config() below via
        -- `require("user").has_biome()` (T1.5 feature flag).
      },
      install_lsp_on_demand = true,
    },
  },

  {
    -- T4.5 — folke/lazydev.nvim: extends lua_ls with full
    -- autocomplete for the lazy.nvim runtime (require("lazy.core.*"),
    -- Lazy spec tables, plugin manager APIs). Without this, the
    -- `lua_ls` server gives "undefined global" errors on every
    -- plugin spec, which drowns out real lint signals. Lazydev
    -- works by:
    --   1. registering a custom :lua LSP path mapping so lua_ls
    --      treats `lazy.core.*` etc. as resolvable;
    --   2. exposing a `Lib` global that completes to
    --      `require("lazy.core.util")` so plugin specs can use
    --      the documented helper.
    "folke/lazydev.nvim",
    ft = { "lua" },
    opts = {
      library = {
        -- Load path mappings for the lazy.nvim runtime + the project's
        -- own plugin specs. The `nvim/lua/plugins` path is the single
        -- source of truth for our plugin surface.
        { path = "lazy.nvim", modules = { "lazy" } },
        { path = "nvim/lua/plugins", modules = {} },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",

    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- si cmp existe
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      local servers = {
        "bashls",
        "cssls",
        "html",
        "jsonls",
        "lua_ls",
        "ts_ls",
        "eslint",
        "angularls",
      }

      -- T3.1 — biome is opt-in. When has_biome() is true, append it to
      -- the server list and let mason-lspconfig set it up. The flag
      -- default is false (per nvim/lua/user/init.lua), so most users
      -- get a clean no-op and prettier continues to format TS/TSX.
      if require("user").has_biome() then
        table.insert(servers, "biome")
        -- biome is a single-file LSP (no need for cmp_nvim_lsp caps)
        lspconfig.biome.setup({
          capabilities = capabilities,
        })
      end

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end

      -- T4.5 — bind `Lib` to `require("lazy.core.util")` in the
      -- global scope so plugin specs can do `Lib.lazy_eq(...)` etc.
      -- with full completion. lazydev.nvim's :lua LSP path mapping
      -- makes this resolve at edit time.
      _G.Lib = require("lazy.core.util")

      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
      })
    end,
  },

}
