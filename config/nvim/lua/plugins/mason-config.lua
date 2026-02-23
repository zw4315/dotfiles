-- Mason 配置：通用工具安装环境
return {
  {
    "mason-org/mason.nvim",
    init = function()
      -- 优先使用 dotfiles 安装的用户级 Go
      local go_path = vim.fn.expand("~/.local/go/bin")
      local current_path = vim.env.PATH or ""
      if vim.fn.isdirectory(go_path) == 1 and not current_path:find(go_path, 1, true) then
        vim.env.PATH = go_path .. ":" .. current_path
      end
    end,
  },
}
