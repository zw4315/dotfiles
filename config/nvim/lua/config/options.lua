-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local provider = vim.fn.expand("~/.local/share/nvim/python-provider-3.13/bin/python")
if vim.fn.executable(provider) == 1 then
  vim.g.python3_host_prog = provider
end
