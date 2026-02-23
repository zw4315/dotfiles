-- Python 开发配置：调试、虚拟环境等
-- LSP 配置已迁移到 languages.lua 使用 LazyVim 官方包
return {
  -- 调试配置（可选，推荐安装）
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      config = function()
        -- 使用系统 python 或虚拟环境中的 debugpy
        local path = require("mason-registry").get_package("debugpy"):get_install_path()
        require("dap-python").setup(path .. "/venv/bin/python")
      end,
    },
  },

  -- 虚拟环境切换（可选，很方便）
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    cmd = "VenvSelect",
    enabled = function()
      return LazyVim.has("telescope.nvim")
    end,
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
  },
}
