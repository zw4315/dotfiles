return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- 可选: 用于在浮动窗口边框显示图标
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- Git 快捷键精简：统一从一个入口进入 UI
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
