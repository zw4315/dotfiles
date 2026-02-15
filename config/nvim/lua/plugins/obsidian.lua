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

      -- ✅ 控制 [[标题]] 自动创建时的文件名（note id）
      note_id_func = function(title)
        if not title or title == "" then
          return tostring(os.time())
        end
        local s = title:lower()
        s = s:gsub("%s+", "-")
        s = s:gsub("[^%w%-]", "")
        s = s:gsub("%-+", "-")
        s = s:gsub("^%-", ""):gsub("%-$", "")
        return s
      end,

      completion = { nvim_cmp = has_cmp },
    }
  end,
}
