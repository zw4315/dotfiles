return {
  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = [[<leader>tt]],
      shade_terminals = false,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      hijack_netrw = true,
      disable_netrw = true,
      view = { width = 36 },
      filters = { dotfiles = false },
      git = { enable = true },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/" },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob",
            "!.git/*",
            "--glob",
            "!node_modules/*",
          },
        },
      })
    end,
  },

  -- Search/replace UI (rg-backed)
  {
    "windwp/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup({})
    end,
  },

  -- Git signs (no heavy deps)
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Outline (Tagbar replacement)
  {
    "stevearc/aerial.nvim",
    opts = {},
  },

  -- Window maximize
  {
    "declancm/maximize.nvim",
    config = function()
      require("maximize").setup({})
    end,
  },

  -- Comment/surround (nvim-native)
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
  },
}

