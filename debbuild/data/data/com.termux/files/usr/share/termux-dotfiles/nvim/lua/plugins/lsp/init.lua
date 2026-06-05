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
      ensure_installed = {
        "bashls",
        "cssls",
        "html",
        "jsonls",
        "lua_ls",
        "ts_ls",
        "eslint",
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
      }

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
