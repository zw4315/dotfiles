# 搜索增强插件

本配置使用两个插件增强搜索和关键词高亮功能。

## nvim-hlslens - 搜索匹配计数

在搜索时显示匹配数量和当前位置，例如 `(2/15)`。

**功能：**
- 搜索 `/pattern` 时显示 `（当前/总数）` 计数
- 实时更新，随光标移动动态显示
- 支持 `n`/`N` 跳转时更新

**按键：**

| 按键 | 功能 |
|------|------|
| `/pattern` | 搜索并自动显示计数 |
| `n` / `N` | 跳转到下一个/上一个匹配，更新计数 |
| `*` / `#` | 搜索当前词并显示计数 |
| `g*` / `g#` | 部分匹配搜索并显示计数 |
| `<leader>l` | 清除搜索高亮 |

**配置：** `config/nvim/lua/plugins/hlslens.lua`

## vim-interestingwords - 多词高亮

同时高亮多个不同的词，每个词用不同颜色显示。

**功能：**
- 使用不同颜色同时高亮多个词
- 在 highlighted 的词之间快速跳转
- 适合标记代码中的多个关注点

**按键：**

| 按键 | 模式 | 功能 |
|------|------|------|
| `<leader>k` | Normal | 高亮/取消高亮当前词 |
| `<leader>k` | Visual | 高亮选中的文本 |
| `<leader>K` | Normal | 清除所有高亮 |

**使用示例：**
```
1. 光标在 "hello" 上，按 <leader>k → "hello" 变黄
2. 光标在 "world" 上，按 <leader>k → "world" 变蓝
3. 两个词同时高亮显示！
4. 按 <leader>K 清除所有高亮
```

**配置：** `config/nvim/lua/plugins/interestingwords.lua`

## 相关配置

```
config/nvim/lua/plugins/
├── hlslens.lua            # 搜索计数配置
└── interestingwords.lua   # 多词高亮配置
```
