return {
  {
    "mfussenegger/nvim-dap",

    keys = {
      { "<F5>", function() require("dap").continue() end },
      { "<F10>", function() require("dap").step_over() end },
      { "<F11>", function() require("dap").step_into() end },
      { "<F12>", function() require("dap").step_out() end },
      { "<leader>b", function() require("dap").toggle_breakpoint() end },
    },

    config = function()
      local dap = require("dap")
      local data_path = vim.fn.stdpath("data")

      -- T3.6: Resolver path del adaptador via Mason registry (con fallback)
      -- Si mason-registry conoce node-debug2-adapter, usar su path instalado.
      -- Si no (registry no disponible o paquete no instalado), fallback al path tradicional.
      local node_debug_path
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok and pcall(function() return mason_registry:is_installed("node-debug2-adapter") end) then
        local pkg = mason_registry.get_package("node-debug2-adapter")
        node_debug_path = pkg:get_install_path() .. "/out/src/nodeDebug.js"
      else
        node_debug_path = data_path .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js"
      end

      dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = { node_debug_path },
      }

      dap.configurations.javascript = {
        {
          type = "node2",
          request = "launch",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
      }

      dap.configurations.typescript = dap.configurations.javascript
    end,
  },
}
