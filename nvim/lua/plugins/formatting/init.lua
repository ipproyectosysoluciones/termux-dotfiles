return {
  {
    "stevearc/conform.nvim",

    event = "BufWritePre",

    config = function()
      -- T3.8: Detectar si biome está habilitado via feature flag
      local has_biome = false
      local ok_user, user = pcall(require, "user")
      if ok_user and user.has_biome then
        has_biome = user.has_biome()
      end

      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = has_biome and { "biome", "prettier" } or { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = has_biome and { "biome", "prettier" } or { "prettier" },
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
