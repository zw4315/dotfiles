-- Mason/Go 环境配置：确保使用正确的 Go 版本
-- 必须在 Mason 之前加载，确保 Go 工具能正确安装
return {
  {
    "mason-org/mason.nvim",
    init = function()
      -- 确保使用新安装的 Go (1.23.6) 而不是系统旧版
      -- 将 /usr/local/go/bin 添加到 PATH 最前面
      local go_path = "/usr/local/go/bin"
      local current_path = vim.env.PATH or ""
      
      -- 避免重复添加
      if not current_path:match(go_path:gsub("-", "%%-")) then
        vim.env.PATH = go_path .. ":" .. current_path
      end
      
      -- 验证 Go 版本
      local handle = io.popen("go version 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        if result:match("go1%.18") then
          vim.notify("Warning: Mason is using old Go version. Please restart nvim.", vim.log.levels.WARN)
        end
      end
    end,
  },
}
