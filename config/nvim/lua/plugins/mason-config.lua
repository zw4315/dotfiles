-- Mason 配置：通用工具安装环境
return {
  {
    "mason-org/mason.nvim",
    init = function()
      -- 确保使用新安装的 Go (1.23.6)
      local go_path = "/usr/local/go/bin"
      local current_path = vim.env.PATH or ""
      if not current_path:match(go_path:gsub("-", "%%-")) then
        vim.env.PATH = go_path .. ":" .. current_path
      end
    end,
  },
}
