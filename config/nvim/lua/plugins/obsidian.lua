return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local notes_dir = vim.fn.expand(vim.env.OBSIDIAN_DIR or "~/mgnt/notes")
      vim.fn.mkdir(notes_dir, "p")
      return {
        workspaces = {
          {
            name = "notes",
            path = notes_dir,
          },
        },
        completion = { nvim_cmp = true },
      }
    end,
  },
}
