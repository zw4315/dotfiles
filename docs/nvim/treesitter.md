# Treesitter 配置说明

本配置使用 `nvim-treesitter` 提供语法高亮、缩进和文本对象功能。

## 已安装的语言 Parser

支持以下语言：

| 语言 | Parser 名称 | 用途 |
|------|------------|------|
| Bash | `bash` | Shell 脚本 |
| C | `c` | C 语言 |
| C++ | `cpp`, `cmake` | C++ 及 CMake |
| Go | `go`, `gomod`, `gosum` | Go 语言及模块 |
| JavaScript/TypeScript | `javascript`, `typescript`, `tsx` | JS/TS 开发 |
| Lua | `lua`, `luadoc`, `luap` | Neovim 配置 |
| Python | `python` | Python 开发 |
| Rust | `rust` | Rust 语言 |
| 其他 | `json`, `yaml`, `toml`, `markdown`, `vim`, `html`, `xml`, `regex` | 配置文件等 |

## 文本对象 (Text Objects)

基于 Treesitter 的智能文本选择：

### 函数

| 按键 | 功能 |
|------|------|
| `vaf` | 选择整个函数（Visual 模式） |
| `vif` | 选择函数内部（不包含函数定义行） |

### 类/结构体

| 按键 | 功能 |
|------|------|
| `vac` | 选择整个类 |
| `vic` | 选择类内部 |

### 代码块

| 按键 | 功能 |
|------|------|
| `vab` | 选择整个代码块 |
| `vib` | 选择代码块内部 |

### 参数

| 按键 | 功能 |
|------|------|
| `vaa` | 选择整个参数（包括分隔符） |
| `via` | 选择参数内部 |

## 移动命令

在函数和类之间快速跳转：

| 按键 | 功能 |
|------|------|
| `]f` | 跳到下一个函数开始 |
| `]F` | 跳到下一个函数结束 |
| `[f` | 跳到上一个函数开始 |
| `[F` | 跳到上一个函数结束 |
| `]c` | 跳到下一个类开始 |
| `]C` | 跳到下一个类结束 |
| `[c` | 跳到上一个类开始 |
| `[C` | 跳到上一个类结束 |

## 故障排除

### 错误：Can not get parser for buffer

如果看到类似错误：
```
E5108: Error executing lua (mini.ai) Can not get parser for buffer X and language Y
```

**解决方法：**

1. 检查当前文件类型：
   ```vim
   :set filetype?
   ```

2. 安装缺失的 parser：
   ```vim
   :TSInstall <语言>
   ```
   例如：`:TSInstall cpp` 或 `:TSInstall rust`

3. 更新所有 parser：
   ```vim
   :TSUpdate
   ```

4. 检查 Treesitter 健康状态：
   ```vim
   :checkhealth nvim-treesitter
   ```

### 添加新语言支持

编辑 `config/nvim/lua/plugins/treesitter.lua`，在 `ensure_installed` 列表中添加新的 parser 名称。

常用语言 parser 名称参考：
- C/C++: `c`, `cpp`, `cmake`
- Go: `go`, `gomod`, `gosum`
- JavaScript/TypeScript: `javascript`, `typescript`, `tsx`
- Rust: `rust`
- Python: `python`
- Java: `java`
- Ruby: `ruby`
- PHP: `php`
- C#: `c_sharp`
- Swift: `swift`
- Kotlin: `kotlin`

完整列表见：[Treesitter Supported Languages](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages)

## 配置文件位置

```
config/nvim/lua/plugins/treesitter.lua
```
