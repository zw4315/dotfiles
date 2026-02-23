# Neovim 源代码阅读指南

本文档说明在源代码阅读场景下，如何使用当前 nvim 配置中的插件和快捷键。

## 快速索引

| 操作类型 | 推荐按键 | 插件 |
|---------|---------|------|
| 跳转到定义 | `gd` 或 `<leader>gd` | LSP / gtags |
| 查找引用 | `gr` 或 `<leader>gr` | LSP / gtags |
| 查看符号大纲 | `<F8>` 或 `<leader>co` | aerial |
| 文件树 | `<leader>e` | neo-tree |
| 全局搜索 | `<leader>gg` | gtags |
| 标记关键点 | `<leader>ba` | bookmarks |

---

## 一、代码跳转（Navigation）

### 1.1 跳转到定义（Definition）

**场景**：查看函数/变量定义在哪里

| 按键 | 插件 | 说明 | 速度 |
|-----|------|------|------|
| `gd` | LSP (内置) | **精确跳转**（语义分析） | 较慢 |
| `<leader>gd` | gtags | **快速跳转**（文本索引） | 快 |

**使用建议**：
- 日常使用：`<leader>gd`（gtags，快速）
- 类型敏感：先按 `gd`（LSP，精确）

**自动生成**：
gutentags 会自动检测项目根目录（包含 `.git`, `Makefile` 等标记），并在以下情况自动生成 gtags：
- 打开项目中的新文件
- 保存文件时
- 缺少 tags 文件时

**无需手动运行 `gtags` 命令！**

### 1.2 查找引用（References）

**场景**：查看哪里使用了某个函数/变量

| 按键 | 插件 | 说明 |
|-----|------|------|
| `gr` | LSP (内置) | 精确查找引用 |
| `<leader>gr` | gtags | 快速查找引用 |

### 1.3 跳转到符号（Symbol）

**场景**：跳转到当前文件中的函数/类

| 按键 | 插件 | 说明 |
|-----|------|------|
| `<leader>gs` | gtags | 搜索当前文件的符号 |
| `<leader>co` | aerial | 打开符号导航窗口 |

---

## 二、代码结构浏览

### 2.1 符号大纲（Outline）

**插件**：aerial.nvim

**按键**：
- `<F8>` - 切换符号大纲侧边栏
- `<leader>co` - 打开符号导航窗口（浮动）
- `<leader>cs` - 打开符号大纲
- `<leader>cS` - 关闭符号大纲

**在 aerial 窗口内**：
- `j/k` - 上下移动
- `<CR>` - 跳转到符号
- `v` - 在垂直分屏中打开
- `s` - 在水平分屏中打开
- `q` - 关闭窗口

### 2.2 文件树

**插件**：neo-tree.nvim

**按键**：
- `<leader>e` - 打开/关闭文件树（LazyVim 默认）
- `<leader>er` - 在文件树中定位当前文件

**特性**：
- 自动跟随当前文件
- 显示隐藏文件
- 支持 git 状态显示

---

## 三、搜索（Search）

### 3.1 全局搜索

**插件**：gtags + nvim-hlslens

| 按键 | 功能 | 说明 |
|-----|------|------|
| `<leader>gg` | gtags grep | 全局文本搜索（类似 grep） |
| `/pattern` | 内置搜索 | 当前文件搜索 |
| `*` | 搜索当前词 | 向前搜索 |
| `#` | 搜索当前词 | 向后搜索 |

### 3.2 搜索增强（hlslens）

**插件**：nvim-hlslens

**特性**：
- 显示匹配计数 `(1/10)`
- 自动高亮所有匹配

**按键**：
- `n` - 下一个匹配（显示计数）
- `N` - 上一个匹配（显示计数）
- `<leader>l` - 清除搜索高亮

### 3.3 多词高亮

**插件**：vim-interestingwords

**场景**：同时高亮多个关键词（不同颜色）

| 按键 | 功能 |
|-----|------|
| `<leader>k` | 高亮/取消当前词 |
| `<leader>k` (Visual) | 高亮选中的文本 |
| `<leader>K` | 清除所有高亮 |

**使用示例**：
1. 在 `function` 上按 `<leader>k` - 变黄
2. 在 `return` 上按 `<leader>k` - 变蓝
3. 两个词同时高亮显示

---

## 四、代码选择（Text Objects）

**插件**：nvim-treesitter + nvim-treesitter-textobjects

### 4.1 选择函数

| 按键 | 选择范围 |
|-----|---------|
| `vaf` | 整个函数（包括定义） |
| `vif` | 函数内部（不包括定义行） |

### 4.2 选择类/结构体

| 按键 | 选择范围 |
|-----|---------|
| `vac` | 整个类 |
| `vic` | 类内部 |

### 4.3 选择代码块

| 按键 | 选择范围 |
|-----|---------|
| `vab` | 整个代码块 |
| `vib` | 代码块内部 |

### 4.4 选择参数

| 按键 | 选择范围 |
|-----|---------|
| `vaa` | 整个参数（含分隔符） |
| `via` | 参数内部 |

### 4.5 函数间跳转

| 按键 | 功能 |
|-----|------|
| `]f` | 下一个函数开始 |
| `]F` | 下一个函数结束 |
| `[f` | 上一个函数开始 |
| `[F` | 上一个函数结束 |

---

## 五、书签（Bookmarks）

**插件**：bookmarks.nvim

**场景**：标记关键代码位置，方便后续回顾

| 按键 | 功能 |
|-----|------|
| `<leader>ba` | 添加/编辑书签 |
| `<leader>bg` | 跳转到书签 |
| `<leader>bl` | 书签列表 |
| `<leader>bn` | 下一个书签 |
| `<leader>bp` | 上一个书签 |
| `<leader>bs` | 搜索书签内容 |
| `<leader>bt` | 书签树视图 |

**使用流程**：
1. 在关键代码处按 `<leader>ba` 添加书签
2. 输入描述（如"重要算法入口"）
3. 之后按 `<leader>bg` 快速跳转

---

## 六、Git 操作

**插件**：lazygit.nvim

| 按键 | 功能 |
|-----|------|
| `<leader>Gg` | 打开 LazyGit |
| `<leader>Gf` | LazyGit（当前文件） |
| `<leader>Gc` | LazyGit 配置 |

**说明**：大写 G 因为 git 是低频操作

---

## 七、完整快捷键速查表

### 代码跳转
```
gd              LSP 跳转到定义（精确）
<leader>gd      gtags 跳转到定义（快速）
gr              LSP 查找引用（精确）
<leader>gr      gtags 查找引用（快速）
<leader>gs      gtags 符号搜索
<leader>gg      gtags 全局搜索
```

### 代码结构
```
<F8>            切换符号大纲
<leader>co      符号导航窗口
<leader>cs      打开符号大纲
<leader>cS      关闭符号大纲
<leader>e       文件树
<leader>er      在文件树定位当前文件
```

### 搜索
```
/pattern        搜索
*               搜索当前词（向前）
#               搜索当前词（向后）
n               下一个匹配
N               上一个匹配
<leader>l       清除高亮
<leader>k       多词高亮
<leader>K       清除多词高亮
```

### 选择（Visual 模式）
```
vaf             选择整个函数
vif             选择函数内部
vac             选择整个类
vic             选择类内部
]f/[f           函数间跳转
```

### 书签
```
<leader>ba      添加书签
<leader>bg      跳转到书签
<leader>bl      书签列表
<leader>bn/bp   下一个/上一个书签
```

### Git
```
<leader>Gg      LazyGit
<leader>Gf      LazyGit（当前文件）
```

---

## 八、推荐的阅读工作流

### 场景 1：初次阅读新项目

1. **打开项目**：`cd project && nvim main.c`
2. **自动索引**：gutentags 会自动生成 gtags 数据库（首次可能需要几秒钟）
3. **查看结构**：按 `<F8>` 查看符号大纲
4. **跳转定义**：`<leader>gd` 跳转到函数定义
5. **标记重点**：`<leader>ba` 添加书签

### 场景 2：追踪函数调用链

1. **查找引用**：`<leader>gr` 找到所有调用处
2. **标记多个点**：`<leader>k` 高亮关键变量
3. **书签跳转**：`<leader>bg` 在书签间切换
4. **文件跳转**：`<leader>e` 查看文件树

### 场景 3：代码 Review

1. **Git 查看**：`<leader>Gg` 打开 LazyGit
2. **文件对比**：在 LazyGit 中查看修改
3. **跳转到行**：在 nvim 中 `<leader>gd` 查看上下文
4. **添加评论**：`<leader>ba` 标记需要关注的地方

---

## 九、常见问题

**Q: gtags 和 LSP 有什么区别？**
A: gtags 基于文本索引，速度快但不够精确；LSP 基于语义分析，精确但较慢。日常使用 gtags，需要精确类型信息时用 LSP。

**Q: 为什么按 `<leader>gd` 没有反应？**
A: gutentags 会自动生成数据库，但首次打开项目可能需要几秒钟。如果长时间无响应，检查项目根目录是否有 `.git` 或 `Makefile` 等标记文件。

**Q: 如何快速切换文件？**
A: 使用 `<leader>e` 打开文件树，或使用 `<leader>fg`（Telescope）模糊搜索。

**Q: 书签数据存储在哪里？**
A: 存储在 SQLite 数据库中，位置：`~/.local/share/bookmarks/bookmarks.db`

---

*文档版本：2024.02.23*
*适用于：dotfiles nvim 配置*
