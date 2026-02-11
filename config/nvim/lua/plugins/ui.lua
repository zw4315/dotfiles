return {
  -- Colorscheme
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({ style = "darker" })
      require("onedark").load()
    end,
  },

  -- Statusline (simple + extensible)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function focus_task_status()
        return vim.g.focus_task_status or ""
      end
      require("lualine").setup({
        options = { theme = "onedark" },
        sections = {
          lualine_c = { "filename" },
          lualine_x = { focus_task_status, "filetype" },
        },
      })
    end,
  },
}

