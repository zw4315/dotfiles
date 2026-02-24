return {
  -- 保留 <leader>gg 给 Diffview（覆盖 LazyVim lazygit 映射）
  {
    "snacks.nvim",
    keys = {
      { "<leader>gg", false },
    },
  },
}
