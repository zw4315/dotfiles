# 字体配置指南

解决 nvim 中图标显示为 `?` 的问题。

## 问题原因

nvim 使用 **Nerd Fonts** 显示各种图标（文件类型、git 状态、诊断符号等）。
如果终端没有安装 Nerd Font，这些图标会显示为 `?`。

## 解决方案

### 方案 1：自动安装（推荐）

运行 dotfiles 安装：
```bash
./init.sh
```

`nerd_fonts` 模块会自动下载并安装 JetBrainsMono Nerd Font。

**安装后**：
1. 重启终端
2. 在终端设置中选择字体：`JetBrainsMono Nerd Font`
3. 重新打开 nvim，图标应正常显示

### 方案 2：手动安装

1. **下载字体**
   - [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip)
   - 或 [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip)

2. **安装字体**
   ```bash
   # 解压到字体目录
   unzip JetBrainsMono.zip -d ~/.local/share/fonts/
   
   # 刷新字体缓存
   fc-cache -fv ~/.local/share/fonts
   ```

3. **配置终端**
   - 打开终端设置
   - 将字体改为 `JetBrainsMono Nerd Font` 或 `FiraCode Nerd Font`
   - 重启终端

## 验证安装

```bash
# 检查字体是否安装
fc-list | grep -i nerd

# 应该看到类似输出：
# /home/user/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf: JetBrainsMono Nerd Font:style=Regular
```

## 推荐字体

| 字体 | 特点 | 下载 |
|------|------|------|
| **JetBrainsMono NF** | 程序员友好，支持连字 | [下载](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip) |
| **FiraCode NF** | 最受欢迎的编程字体 | [下载](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip) |
| **Hack NF** | 清晰易读 | [下载](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip) |

## 终端配置示例

### Windows Terminal
1. 设置 → 外观 → 字体 → 选择 `JetBrainsMono Nerd Font`

### iTerm2 (macOS)
1. Preferences → Profiles → Text → Font → 选择 `JetBrainsMono Nerd Font`

### GNOME Terminal
1. 编辑 → 首选项 → 文本 → 自定义字体 → 选择 `JetBrainsMono Nerd Font`

### VS Code Terminal
```json
"terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"
```

## 常见问题

**Q: 安装后 nvim 还是显示 ?**
A: 确保终端字体已设置为 Nerd Font，不是系统默认字体。

**Q: 安装后终端文字重叠？**
A: 可能是字体大小问题，尝试调整终端字体大小（推荐 12-14pt）。

**Q: 可以使用系统自带字体吗？**
A: 不行，必须使用 Nerd Font 版本（带 NF 后缀）。

---

*最后更新：2024.02.23*
