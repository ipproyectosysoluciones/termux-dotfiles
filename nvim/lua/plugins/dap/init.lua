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

      -- Node.js / TypeScript (vía node)
      dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
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
