-- Python 开发配置：LSP、调试、跳转等
return {
  -- Python LSP 配置
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Pyright: Python 语言服务器，提供跳转、补全、诊断等功能
        pyright = {
          settings = {
            python = {
              analysis = {
                -- 类型检查级别: off, basic, standard, strict
                typeCheckingMode = "basic",
                -- 自动导入
                autoImportCompletions = true,
                -- 诊断设置
                diagnosticMode = "workspace",
                -- 使用库类型存根
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        -- 可选：Ruff LSP（超快的 Python linter 和代码格式化工具）
        -- 需要: pip install ruff
        ruff = {
          settings = {
            -- 使用 ruff 进行 organize imports
            organizeImports = true,
            -- 使用 ruff 进行代码修复
            fixAll = true,
          },
        },
      },
    },
  },

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
