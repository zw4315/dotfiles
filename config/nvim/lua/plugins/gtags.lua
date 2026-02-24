-- gtags.nvim 配置 - 纯 Lua 实现，不依赖 cscope
return {
  {
    "wsdjeg/gtags.nvim",
    event = "VeryLazy",
    cmd = { "Gtags" },
    dependencies = {
      "rcarriga/nvim-notify",
      "wsdjeg/job.nvim",
      "wsdjeg/logger.nvim",
    },
    keys = {
      {
        "<leader>td",
        function()
          require("gtags").global({})
        end,
        desc = "Gtags Definition",
      },
      {
        "<leader>tr",
        function()
          require("gtags").global({ "-r" })
        end,
        desc = "Gtags References",
      },
      {
        "<leader>ts",
        function()
          require("gtags").global({ "-s" })
        end,
        desc = "Gtags Symbol",
      },
      {
        "<leader>tf",
        function()
          require("gtags").global({ "-f", "%" })
        end,
        desc = "Gtags Current File",
      },
    },
    config = function()
      local gtags = require("gtags")
      gtags.setup({ auto_update = false })

      local function project_db_file()
        local cache_dir = vim.fn.stdpath("data") .. "/gtags.nvim/"
        local project_hash = vim.fn.getcwd():gsub("/", "_"):gsub("\\", "_"):gsub(":", "_")
        return cache_dir .. project_hash .. "/GTAGS"
      end

      local function is_real_file_buffer(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        if vim.bo[bufnr].buftype ~= "" then
          return false
        end
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return false
        end
        return vim.fn.filereadable(name) == 1
      end

      local gtags_group = vim.api.nvim_create_augroup("GtagsAutoUpdate", { clear = true })

      -- 打开已有文件：若数据库不存在则自动全量生成
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = gtags_group,
        pattern = "*",
        callback = function(args)
          if not is_real_file_buffer(args.buf) then
            return
          end
          if vim.fn.filereadable(project_db_file()) ~= 1 then
            gtags.update(false)
          end
        end,
      })

      -- 保存文件：单文件增量更新
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = gtags_group,
        pattern = "*",
        callback = function(args)
          if not is_real_file_buffer(args.buf) then
            return
          end
          gtags.update(true)
        end,
      })

      -- 关闭编辑器时：再做一次全量更新（兜底）
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = gtags_group,
        callback = function()
          if vim.fn.filereadable(project_db_file()) == 1 then
            gtags.update(false)
          end
        end,
      })
    end,
  },
}
