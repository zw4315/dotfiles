-- Neovim config (lazy.nvim) with feature parity to the existing Vim setup.

-- Share custom Vimscript helpers/plugins living in ~/.vim (linked by this repo).
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

-- Leader
vim.g.mapleader = "\\"

-- Basic options (mirror files/vimrc)
vim.opt.modelines = 0
vim.opt.compatible = false
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

-- Colors
vim.opt.termguicolors = true

-- Plugin config globals (set before plugins load)
vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
vim.g.gutentags_modules = { "ctags", "gtags_cscope" }
vim.g.gutentags_project_root = { ".root" }
vim.g.gutentags_plus_switch = 1

vim.g.zw_rg_default_mappings = 1

vim.g.bookmark_sign = "♥"
vim.g.bookmark_highlight_lines = 1

-- fzf.vim: use ripgrep by default (same as files/vimrc)
vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'

-- Keymaps (mirror files/vimrc)
vim.keymap.set("n", "<leader>g", ":Rg ", { noremap = true })
vim.keymap.set("n", "<C-n>", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>n", ":NERDTreeFind<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":Files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>e", function()
  vim.api.nvim_feedkeys(":e ./", "n", false)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>m", ":MaximizerToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg('"', vim.fn.expand("%:p"))
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>yf", function()
  vim.fn.setreg('"', vim.fn.expand("%:t"))
end, { noremap = true, silent = true })

vim.keymap.set("n", "<F8>", ":TagbarToggle<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>x", "oinbox::<CR>::inbox<Esc>O", { noremap = true, silent = true })
vim.keymap.set("i", "<leader>x", "<Esc>oinbox::<CR>::inbox<Esc>O", { noremap = true, silent = true })

vim.keymap.set("i", "<F5>", function()
  return os.date("%Y-%m-%d %H:%M:%S")
end, { expr = true, noremap = true, silent = true })

vim.keymap.set("n", "<leader>o", ":History<CR>", { noremap = true, silent = true })

-- Format C/C++ on save (same behavior as :%!clang-format)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.h", "*.cc" },
  command = "%!clang-format",
})

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Terminal
  { "voldikss/vim-floaterm" },

  -- Switch header/source
  { "vim-scripts/a.vim" },

  -- Highlight
  { "t9md/vim-quickhl" },

  -- Tags / gtags
  { "ludovicchabant/vim-gutentags" },
  { "skywind3000/gutentags_plus" },

  -- Git
  { "tpope/vim-fugitive" },

  -- Markdown tables
  { "dhruvasagar/vim-table-mode" },
  { "godlygeek/tabular" },

  -- File navigation / fuzzy search
  { "preservim/nerdtree" },
  { "junegunn/fzf" },
  { "junegunn/fzf.vim" },
  { "preservim/tagbar" },
  { "preservim/vim-markdown" },

  -- Syntax / colors
  { "octol/vim-cpp-enhanced-highlight" },
  { "morhetz/gruvbox" },
  { "joshdick/onedark.vim", priority = 1000, config = function()
    vim.cmd.colorscheme("onedark")
  end },

  -- Editing
  { "tpope/vim-surround" },
  { "szw/vim-maximizer" },
  { "tpope/vim-commentary" },

  -- Statusline (keep airline because custom focus_task.vim integrates with it)
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },

  -- Bookmarks
  { "MattesGroeger/vim-bookmarks" },
})

-- Floaterm keymaps (custom autoload lives under ~/.vim/autoload/zw)
vim.g.zw_floaterm_prefix = "<leader>t"
pcall(function()
  vim.cmd("call zw#floaterm#setup()")
end)

-- Some of the shared Vimscript under ~/.vim/after expects plugins to be present.
-- Re-source the rg/fzf integration after lazy has updated runtimepath.
pcall(function()
  vim.cmd("silent! runtime after/plugin/rg_fzf.vim")
end)
