return {
  -- Keep a few legacy Vim plugins that are still useful and work in Neovim.
  { "t9md/vim-quickhl" },
  { "dhruvasagar/vim-table-mode" },
  { "godlygeek/tabular" },
  { "preservim/vim-markdown" },

  -- Tags (optional; enabled only when tools exist, see lua/zw/options.lua)
  { "ludovicchabant/vim-gutentags", enabled = vim.g.gutentags_enabled ~= 0 },
  { "skywind3000/gutentags_plus", enabled = vim.g.gutentags_enabled ~= 0 },
}

