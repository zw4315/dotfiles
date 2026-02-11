# 给用户看的 Neovim 使用说明（LazyVim 方案）

目标：在新机器上用 `nvim + LazyVim` 快速获得“开箱即用”的编辑体验，并增加“笔记双链/反向链接（backlinks）”能力。

> 说明：`./init.sh` 的 `nvim` 模块只负责把本仓库的 `config/nvim` 链接到 `~/.config/nvim`。因此你可以把 `config/nvim` 做成 LazyVim 结构，`init.sh` 不需要改。

## 1) 新机器最小准备（Linux）

- 安装 `nvim`、`git`、`rg`（ripgrep）
- 建议再装：`fd`（telescope 更好用）

## 2) 安装（用本仓库链接配置）

1. clone 本仓库到任意目录
2. 确认 `profiles/linux.sh` 里启用了 `nvim=1`
3. 执行：
   - 预演：`./init.sh --dry-run`
   - 真正执行：`./init.sh`

完成后，`~/.config/nvim` 会指向本仓库的 `config/nvim`。

## 3) 把 `config/nvim` 变成 LazyVim（一次性动作）

LazyVim 推荐用它的 “starter” 作为 `~/.config/nvim` 内容。

如果你想让本仓库“默认就是 LazyVim”，做法是：

- 用 LazyVim starter 的目录内容替换本仓库的 `config/nvim/`
- 然后把你自己的定制都放在 `config/nvim/lua/plugins/*.lua`

之后打开 `nvim`，LazyVim 会自动 bootstrap 并提示安装/同步。

## 4) 示例：在 LazyVim 里加“笔记双链/backlinks”（obsidian.nvim）

推荐插件：`epwalsh/obsidian.nvim`（偏 Obsidian 工作流：链接、backlinks、daily note 等）。

在 `config/nvim/lua/plugins/obsidian.lua` 新建一个文件，写入类似配置：

```lua
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = vim.fn.expand("~/mgnt/notes"),
        },
      },
      completion = { nvim_cmp = true },
      -- 你也可以在这里设置 daily notes、templates、frontmatter 等
    },
  },
}
```

打开 `nvim` 后执行 `:Lazy sync`，然后在 markdown 文件里常用命令：

- `:ObsidianBacklinks`：查看当前 note 的反向链接（backlinks）
- `:ObsidianLinks`：查看当前 note 的外链
- `:ObsidianQuickSwitch`：快速跳转到其他 note
- `:ObsidianNew`：创建新 note

如果你希望 notes 目录在不同机器/不同 OS 都一致，建议把 `~/mgnt/notes` 作为统一入口（Windows/WSL 则让 home 下也有同名目录，或在各自 profile 里调整 `path`）。

## 5) 常见问题

- Q：我运行 `./init.sh` 后，LazyVim 的文件被覆盖了怎么办？
  - A：`./init.sh` 会把 `config/nvim` 链接到 `~/.config/nvim`。如果你想用 LazyVim，就应该让 `config/nvim` 本身就是 LazyVim starter（见第 3 节），或临时把 `profiles/linux.sh` 里的 `nvim=1` 关掉，改为自己管理 `~/.config/nvim`。

