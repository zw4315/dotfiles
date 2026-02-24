# Neovim 源码阅读工作流

本文档面向“读代码/追调用链”场景，基于当前 dotfiles 实际配置。

## 快速入口

| 场景 | 快捷键 | 说明 |
|---|---|---|
| 跳到定义（快） | `<leader>td` | gtags |
| 查找引用（快） | `<leader>tr` | gtags |
| 符号检索 | `<leader>ts` | gtags |
| 当前文件符号 | `<leader>tf` | gtags |
| 精确语义跳转 | `gd` / `gr` | LSP |
| 文件树定位 | `<leader>e` | Snacks Explorer |
| 符号大纲 | `<F8>` / `<leader>co` | Aerial |
| 标记关注点 | `<leader>ba` | Bookmarks |

## gtags 自动数据库策略

当前实现（`config/nvim/lua/plugins/gtags.lua`）：

1. 打开已有文件（`BufReadPost`）时，如果项目数据库不存在，则自动全量生成。
2. 保存文件（`BufWritePost`）时，对当前文件做单文件增量更新。
3. 退出 Neovim（`VimLeavePre`）时，触发一次全量更新兜底。

因此一般不需要手动运行 `gtags`。

## 推荐阅读流程

1. `<leader>td` 先快速跳定义，浏览调用链。
2. 在关键位置使用 `<leader>ba` 标记书签。
3. 需要确认语义时，再使用 LSP 的 `gd` / `gr`。
4. 用 `<leader>co` 或 `<F8>` 观察当前文件结构。

## 搜索增强

- `n` / `N`：hlslens 提示当前匹配位置。
- `<leader>k`：多词高亮关键变量。
- `<leader>K`：清理多词高亮。
- `<leader>l`：清除搜索高亮。

## Git 查看改动

- `<leader>gg`：打开 Diffview（默认横向双栏对比）。
- `<leader>gq`：关闭 Diffview。
- `<leader>gh`：查看当前文件历史。

---

最后更新：2026-02-24
