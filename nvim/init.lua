vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Lazy config
local lazy_config = require("configs.lazy")

-- Plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    branch = "v2.5",
    lazy = false,
    import = "nvchad.plugins",
  },

  { import = "plugins" },

}, lazy_config)

-- Base46 cache
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- Core configs
require("options")
require("nvchad.autocmds")

-- Delayed mappings
vim.schedule(function()
  require("mappings")
end)
