-- Core editor options + globals (set before plugins load).

vim.opt.modelines = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.path:append("**")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 99
vim.opt.foldenable = true

vim.opt.termguicolors = true

-- External-tool defaults
vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'

-- gutentags: only enable if tools exist (cross-platform friendly)
local has_ctags = vim.fn.executable("ctags") == 1
local has_gtags = vim.fn.executable("gtags") == 1
if has_ctags or has_gtags then
  vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
  vim.g.gutentags_modules = {}
  if has_ctags then
    table.insert(vim.g.gutentags_modules, "ctags")
  end
  if has_gtags then
    table.insert(vim.g.gutentags_modules, "gtags_cscope")
  end
  vim.g.gutentags_project_root = { ".root", ".git" }
  vim.g.gutentags_plus_switch = 1
else
  vim.g.gutentags_enabled = 0
end

