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
  -- 设置快捷键
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (当前文件)" },
    { "<leader>gc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit 配置" },
  },
}
