return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Ensure `require("cmp")` works when obsidian.nvim initializes.
      "hrsh7th/nvim-cmp",
    },
    opts = function()
      local notes_dir = vim.fn.expand(vim.env.OBSIDIAN_DIR or "~/mgnt/notes")
      vim.fn.mkdir(notes_dir, "p")
      local has_cmp = pcall(require, "cmp")
      return {
        workspaces = {
          {
            name = "notes",
            path = notes_dir,
          },
        },
        completion = { nvim_cmp = has_cmp },
      }
    end,
  },
}
