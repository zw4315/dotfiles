# Bookmarks.nvim 使用文档

## 简介

[Bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim) 是一个强大的 Neovim 书签管理插件，使用 SQLite 数据库存储书签数据，支持 Telescope 快速检索，可以方便地在项目中的不同位置之间跳转。

## 特性

- 🗄️ **SQLite 存储**: 使用 SQLite 持久化存储书签
- 🔍 **Telescope 集成**: 快速搜索和跳转到书签
- 🌳 **树形视图**: 以树形结构查看书签
- 📁 **文件分类**: 自动按文件组织书签
- 🏷️ **名称标记**: 为书签添加描述性名称
- 🔄 **历史记录**: 记录书签访问历史，便于快速回溯

## 安装

插件已通过 `lazy.nvim` 配置在 `config/nvim/lua/plugins/bookmarks.lua` 中，会自动加载。

### 依赖

- `kkharji/sqlite.lua`: SQLite 数据库支持
- `nvim-telescope/telescope.nvim`: 模糊搜索界面
- `stevearc/dressing.nvim`: 更好的 UI 体验（可选但推荐）

### 检查安装状态

在 Neovim 中运行以下命令检查插件运行状态：

```vim
:BookmarksInfo
```

## 快捷键

书签插件的所有快捷键都以 `<leader>b` 开头（b = bookmark）：

| 快捷键 | 命令 | 描述 |
|--------|------|------|
| `<leader>ba` | `:BookmarksMark` | 在当前行添加/编辑/切换书签 |
| `<leader>bg` | `:BookmarksGoto` | 跳转到书签（选择器） |
| `<leader>bl` | `:BookmarksLists` | 选择并切换书签列表 |
| `<leader>bn` | `:BookmarksGotoNext` | 跳转到下一个书签 |
| `<leader>bp` | `:BookmarksGotoPrev` | 跳转到上一个书签 |
| `<leader>bN` | `:BookmarksGotoNextInList` | 跳转到列表中下一个书签 |
| `<leader>bP` | `:BookmarksGotoPrevInList` | 跳转到列表中上一个书签 |
| `<leader>bs` | `:BookmarksGrep` | 搜索书签内容（Grep） |
| `<leader>bi` | `:BookmarksInfo` | 显示书签插件信息 |
| `<leader>bt` | `:BookmarksTree` | 打开书签树形视图 |
| `<leader>bq` | `:BookmarksQuery` | 查询书签（SQL） |
| `<leader>bc` | `:BookmarksCommands` | 打开命令选择器 |

## 使用方法

### 1. 添加书签

将光标移到想要标记的行，按下：

```
<leader>ba
```

输入书签名称（可选），按回车确认。

### 2. 查看书签列表

**选择书签列表**（会切换到该列表并显示其中的书签）：

```
<leader>bl
```

在列表选择器中：
- `<CR>`: 切换到选中的列表并显示书签

**打开树形视图**查看所有书签（层级结构）：

```
<leader>bt
```

**查询书签**（SQL 方式）：

```
<leader>bq
```

### 3. 搜索书签

使用 Grep 搜索书签内容：

```
<leader>bs
```

### 4. 书签跳转

**跳转到指定书签**（使用选择器）：

```
<leader>bg
```

在选择器窗口中：
| 按键 | 操作 |
|------|------|
| `<CR>` | 跳转到书签 |
| `<C-v>` | 在垂直分割窗口中打开 |
| `<C-s>` | 在水平分割窗口中打开 |
| `<C-t>` | 在新标签页中打开 |
| `<C-d>` | **删除选中的书签** |

**在书签之间快速跳转**：

- `<leader>bn`: 跳转到下一个书签（按行号）
- `<leader>bp`: 跳转到上一个书签（按行号）
- `<leader>bN`: 跳转到列表中下一个书签
- `<leader>bP`: 跳转到列表中上一个书签

### 5. 删除书签

删除书签有以下几种方式：

**方式 1：在选择器中删除**

打开书签选择器 (`<leader>bg`) 或列表选择器 (`<leader>bl`)，选中要删除的书签，按：

```
<C-d>   (Ctrl + d)
```

**方式 2：在树形视图中删除**

打开树形视图 (`<leader>bt`)，移动光标到要删除的书签，按：

```
D   (大写 D)
```

**方式 3：通过重新标记删除**

将光标移到已有书签的行，按 `<leader>ba`，然后输入**空名称**（直接回车），即可删除该书签。

### 6. 树形视图

打开书签的树形结构视图：

```
<leader>bt
```

在树形视图中：

**导航操作**：
| 按键 | 操作 |
|------|------|
| `j/k` | 上下移动 |
| `h` | 折叠文件夹 |
| `l` 或 `<CR>` | 展开/折叠文件夹或跳转到书签 |
| `o` | 展开/折叠或跳转 |
| `u` | 向上返回一级 |
| `.` | 将当前列表设为根节点 |
| `q` 或 `<Esc>` | 关闭树形视图 |

**书签操作**：
| 按键 | 操作 |
|------|------|
| `g` | 跳转到书签位置 |
| `r` | 重命名节点 |
| `D` | **删除节点** |
| `x` | 剪切节点 |
| `c` | 复制节点 |
| `p` | 粘贴节点 |
| `m` | 设为活动列表 |

**列表操作**：
| 按键 | 操作 |
|------|------|
| `a` | 创建新列表 |
| `<localleader>k` | 上移节点 |
| `<localleader>j` | 下移节点 |
| `R` | 刷新视图 |
| `t` | 反转排序 |

**其他**：
| 按键 | 操作 |
|------|------|
| `i` | 显示节点信息 |
| `P` | 预览书签内容 |
| `+` | 添加到 Aider |
| `=` | 以只读方式添加到 Aider |
| `-` | 从 Aider 移除 |

## 数据存储

### 存储位置

书签数据存储在 SQLite 数据库中：

```
~/.local/share/nvim/bookmarks/bookmarks.db
```

### 备份

当插件有大的版本更新时（major version change），建议备份书签数据库：

```bash
# 备份
cp ~/.local/share/nvim/bookmarks/bookmarks.db ~/.local/share/nvim/bookmarks/bookmarks.db.backup

# 恢复
cp ~/.local/share/nvim/bookmarks/bookmarks.db.backup ~/.local/share/nvim/bookmarks/bookmarks.db
```

## 高级配置

### 自定义配置

编辑 `config/nvim/lua/plugins/bookmarks.lua` 中的 `opts` 表：

```lua
opts = {
  -- 修改图标
  signs = {
    mark = { icon = "📌", color = "blue", line_bg = "#1e3a5f" },
  },
  
  -- 修改快捷键
  keymaps = {
    add_bookmark = "mm",
    show_bookmarks = "ml",
    -- ...
  },
  
  -- 修改存储位置
  storage = {
    dir = "/your/custom/path",
    filename = "my_bookmarks.db",
  },
}
```

### 可用命令

| 命令 | 描述 |
|------|------|
| `:BookmarksMark [name]` | 添加/编辑/切换当前行书签 |
| `:BookmarksDesc` | 为当前书签添加描述 |
| `:BookmarksGoto` | 跳转到书签（选择器） |
| `:BookmarksGotoNext` | 跳转到下一个书签（按行号） |
| `:BookmarksGotoPrev` | 跳转到上一个书签（按行号） |
| `:BookmarksGotoNextInList` | 跳转到列表中下一个书签 |
| `:BookmarksGotoPrevInList` | 跳转到列表中上一个书签 |
| `:BookmarksGrep` | Grep 搜索书签内容 |
| `:BookmarksLists` | 选择书签列表 |
| `:BookmarksNewList` | 创建新书签列表 |
| `:BookmarksTree` | 打开书签树形视图 |
| `:BookmarksQuery` | 查询书签（SQL） |
| `:BookmarksCommands` | 打开命令选择器 |
| `:BookmarksInfo` | 显示插件运行状态 |
| `:BookmarksInfoCurrentBookmark` | 显示当前书签信息 |
| `:BookmarkRebindOrphanNode` | 重新绑定孤儿节点到根节点 |

## 使用建议

1. **项目入口点**: 为项目的 main 文件、配置文件添加书签
2. **关键函数**: 为经常需要查看或修改的核心函数添加书签
3. **TODO 标记**: 为需要后续处理的代码位置添加书签
4. **学习笔记**: 阅读源码时，为重要逻辑添加书签以便复习

## 故障排查

### 书签无法保存

1. 检查 SQLite 是否正常安装：
   ```vim
   :checkhealth sqlite
   ```

2. 检查存储目录权限：
   ```bash
   ls -la ~/.local/share/nvim/bookmarks/
   ```

3. 查看插件信息：
   ```vim
   :BookmarksInfo
   ```

### Telescope 搜索不工作

确保 Telescope 插件已正确安装：

```vim
:checkhealth telescope
```

### 图标显示为方块

确保你的终端字体支持 emoji 或安装 [Nerd Font](https://www.nerdfonts.com/)。

## 参考链接

- [Bookmarks.nvim GitHub](https://github.com/LintaoAmons/bookmarks.nvim)
- [默认配置](https://github.com/LintaoAmons/bookmarks.nvim/blob/main/lua/bookmarks/default-config.lua)
