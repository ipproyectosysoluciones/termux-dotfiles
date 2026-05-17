return {
  {
    "stevearc/conform.nvim",

    event = "BufWritePre",

    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },

          lua = { "stylua" },
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      vim.keymap.set("n", "<leader>fm", function()
        require("conform").format({ async = true })
      end)
    end,
  },
}
