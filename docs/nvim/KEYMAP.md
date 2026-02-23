# Neovim 快捷键速查（当前配置）

本文档只记录本仓库自定义/重定义的快捷键。LazyVim 默认键位请参考官方文档。

## 命名约定

- `<leader>g*`：代码导航（gtags）
- `<leader>gg`：Git 单一入口（LazyGit）
- `<leader>o*`：Notes（telekasten）
- `<leader>b*`：Bookmarks
- `<leader>u*`：UI/开关

## 代码导航（gtags）

| 快捷键 | 功能 |
|---|---|
| `<leader>gd` | gtags 定义 |
| `<leader>gr` | gtags 引用 |
| `<leader>gs` | gtags 符号 |
| `<leader>gf` | gtags 当前文件 |
| `:Gtags ...` | 原生命令入口 |

说明：

- `gd` / `gr`（无 `<leader>`）仍可用于 LSP 精确跳转。
- `<leader>gd` / `<leader>gs` 这些键位已从 LazyVim 默认 Git 映射中释放给 gtags。

## Git（精简）

| 快捷键 | 功能 |
|---|---|
| `<leader>gg` | 打开 LazyGit |

说明：

- 不再维护大量 Git 子快捷键，进入 LazyGit 后通过 UI 操作。

## Notes（telekasten）

| 快捷键 | 功能 |
|---|---|
| `<leader>op` | Notes Panel |
| `<leader>od` | Today |
| `<leader>ow` | This Week |
| `<leader>on` | New Note |
| `<leader>ol` | Follow Link |
| `<leader>oc` | Calendar |
| `<leader>of` | Find Notes |
| `<leader>os` | Search Notes |

额外增强：

- Markdown 中光标位于 `[[wikilink]]` 内时，可尝试 `<C-CR>` 跟随/创建链接（终端兼容性相关）。

## 书签（bookmarks.nvim）

| 快捷键 | 功能 |
|---|---|
| `<leader>ba` | 添加/编辑书签 |
| `<leader>bg` | 跳转到书签 |
| `<leader>bl` | 书签列表 |
| `<leader>bn` / `<leader>bp` | 下一个/上一个书签 |
| `<leader>bN` / `<leader>bP` | 列表中下一个/上一个 |
| `<leader>bs` | 搜索书签 |
| `<leader>bt` | 书签树 |
| `<leader>bq` | SQL 查询 |
| `<leader>bi` | 书签信息 |
| `<leader>bc` | 书签命令面板 |

## 搜索与高亮

| 快捷键 | 功能 |
|---|---|
| `n` / `N` | 下一项/上一项（hlslens 增强） |
| `<leader>k` | 高亮当前词（normal）/选区（visual） |
| `<leader>K` | 清除多词高亮 |
| `<leader>l` | 清除搜索高亮（`noh`） |

## UI

| 快捷键 | 功能 |
|---|---|
| `<leader>ui` | Nerd Font 图标模式切换（glyph/ascii） |
| `<leader>er` | 在 Neo-tree 中定位当前文件 |

## 语言相关

| 快捷键 | 功能 |
|---|---|
| `<leader>cv` | Python 虚拟环境切换（VenvSelect） |
| `<F8>` | Aerial 符号大纲开关 |
| `<leader>co` | Aerial 符号导航 |
| `<leader>cs` / `<leader>cS` | 打开/关闭符号大纲 |

---

最后更新：2026-02-24
