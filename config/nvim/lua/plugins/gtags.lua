-- gtags 配置 - 支持全局代码跳转
-- 与 LSP 共存，提供快速代码导航

return {
  -- 自动生成 tags（ctags + gtags）
  {
    "ludovicchabant/vim-gutentags",
    event = "VeryLazy",
    config = function()
      -- 启用 gtags 模块
      vim.g.gutentags_modules = { "ctags", "gtags_cscope" }
      
      -- 缓存目录
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
      
      -- 项目根目录标记
      vim.g.gutentags_project_root = { ".root", ".git", ".hg", ".svn", ".bzr", 
        "_darcs", "package.json", "Cargo.toml", "go.mod", "Makefile", "CMakeLists.txt" }
      
      -- 关闭自动跳转目录
      vim.g.gutentags_plus_switch = 1
      
      -- 调试选项（需要时取消注释）
      -- vim.g.gutentags_trace = 1
      -- vim.g.gutentags_define_advanced_commands = 1
    end,
  },
  
  -- gtags 增强插件
  {
    "skywind3000/gutentags_plus",
    event = "VeryLazy",
    dependencies = { "ludovicchabant/vim-gutentags" },
    config = function()
      -- 按键映射
      local opts = { noremap = true, silent = true }
      
      -- gtags 跳转
      -- 使用小写 g 因为 gtags 是高频操作
      vim.keymap.set("n", "<leader>gd", "<cmd>Gtags<cr>", vim.tbl_extend("force", opts, { desc = "Gtags definition" }))
      vim.keymap.set("n", "<leader>gr", "<cmd>Gtags -r<cr>", vim.tbl_extend("force", opts, { desc = "Gtags references" }))
      vim.keymap.set("n", "<leader>gs", "<cmd>Gtags -s<cr>", vim.tbl_extend("force", opts, { desc = "Gtags symbol" }))
      vim.keymap.set("n", "<leader>gg", "<cmd>Gtags -g<cr>", vim.tbl_extend("force", opts, { desc = "Gtags grep" }))
      
      -- 与 LSP 配合：小写 g 前缀用于高频的 gtags
      -- <leader>gd - gtags 定义（快速）
      -- gd - LSP 定义（精确）
      -- <leader>gr - gtags 引用（快速）
      -- gr - LSP 引用（精确）
      -- <leader>gg - gtags grep（高频操作，使用小写 g）
    end,
  },
}
