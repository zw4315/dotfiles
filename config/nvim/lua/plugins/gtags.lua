-- gtags.nvim 配置 - 纯 Lua 实现，不依赖 cscope
return {
  {
    "wsdjeg/gtags.nvim",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-notify",
      "wsdjeg/job.nvim",
      "wsdjeg/logger.nvim",
    },
    config = function()
      local gtags = require("gtags")
      gtags.setup()

      -- 自动更新 gtags 数据库
      local gtags_group = vim.api.nvim_create_augroup("GtagsAutoUpdate", { clear = true })

      -- 打开文件时，如果数据库不存在则生成
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = gtags_group,
        pattern = "*",
        callback = function()
          local cache_dir = vim.fn.stdpath("data") .. "/gtags.nvim/"
          local project_hash = vim.fn.getcwd():gsub("/", "_"):gsub("\\", "_"):gsub(":", "_")
          local gtags_file = cache_dir .. project_hash .. "/GTAGS"

          -- 如果数据库不存在，生成完整数据库
          if vim.fn.filereadable(gtags_file) ~= 1 then
            gtags.update()
          end
        end,
      })

      -- 保存文件后单文件更新数据库
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = gtags_group,
        pattern = "*",
        callback = function()
          -- 使用 single_update 模式更新当前文件
          gtags.update(true)
        end,
      })
    end,
  },
}
