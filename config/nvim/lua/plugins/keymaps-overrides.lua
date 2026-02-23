return {
  -- 关闭 LazyVim 默认的 g* Git 键位，给 gtags 使用
  {
    "snacks.nvim",
    keys = {
      { "<leader>gd", false },
      { "<leader>gs", false },
      { "<leader>gg", false },
    },
  },
}
