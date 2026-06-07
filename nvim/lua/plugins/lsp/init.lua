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
