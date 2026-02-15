return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  opts = function()
    local notes_dir = vim.fn.expand(vim.env.OBSIDIAN_DIR or "~/mgnt/notes")
    vim.fn.mkdir(notes_dir, "p")
    local has_cmp = pcall(require, "cmp")

    return {
      workspaces = {
        { name = "notes", path = notes_dir },
      },

      -- ✅ 所有“新建笔记”（包括从 [[link]] 触发的创建）都放到 vault 根目录
      new_notes_location = "notes_subdir",
      notes_subdir = "",

      -- ✅ 日记仍然固定在 notes/daily/
      daily_notes = {
        folder = "daily",
      },

      completion = { nvim_cmp = has_cmp },
    }
  end,
}
