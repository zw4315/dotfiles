-- Neovim entrypoint (keep this file lightweight).
-- Most config lives under lua/zw and lua/plugins.

-- Leader must be set before plugins/keymaps.
vim.g.mapleader = "\\"

require("zw.options")
require("zw.commands")
require("zw.keymaps")
require("zw.autocmds")
require("zw.transparent").setup()
require("zw.inbox").setup()
require("zw.focus_task").setup()

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  if vim.env.DOTFILES_NVIM_SKIP_BOOTSTRAP == "1" then
    vim.schedule(function()
      vim.notify(
        ("lazy.nvim not found at %s (bootstrap skipped)"):format(lazypath),
        vim.log.levels.WARN
      )
    end)
    return
  end
  if vim.fn.executable("git") == 1 then
    pcall(function()
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end)
  end
end
if not uv.fs_stat(lazypath) then
  vim.schedule(function()
    vim.notify(
      ("lazy.nvim not found at %s (install it or check network access)"):format(lazypath),
      vim.log.levels.WARN
    )
  end)
  return
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = false },
  install = { colorscheme = { "onedark", "gruvbox" } },
})

