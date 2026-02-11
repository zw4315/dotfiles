# dotfiles 开发计划（分层与跨平台）

目标：把当前偏 Ubuntu/Linux 的单层 `files/` 结构，演进为“平台层 + 软件层 + 个人层”的可组合结构，同时保持安装方式简单、可回滚、可增量迁移。

## 1. 设计原则

- **单一真相源**：每个最终落地到 `$HOME` 的配置文件，明确来自哪个层（common/os/app/local），避免同名文件在多个地方互相覆盖导致难以追踪。
- **可组合**：平台（Windows/Linux/macOS/WSL）与软件（vim/nvim/git/tmux/…）能独立开关。
- **可增量迁移**：允许一段时间内旧结构与新结构共存，先不打破现有 `setup` 的使用体验。
- **可审计**：安装时输出“链接/覆盖/备份”清单；支持 dry-run。
- **遵循 XDG（尽量）**：新配置优先落在 `~/.config/<app>`，旧的 `~/.vimrc`/`~/.vim/` 等保留兼容层。

## 2. 推荐目录结构（最终形态）

建议采用“目标目录镜像 + 分层 overlay”的方式：把要链接到 `$HOME` 的东西放在类似 `home/`、`config/` 的目录下；再按平台/软件做 overlay。

```
dotfiles/
  home/                       # 镜像 $HOME（含点文件）
    .bashrc
    .gitconfig
    .tmux.conf
    .ssh/config
  config/                     # 镜像 $XDG_CONFIG_HOME（默认 ~/.config）
    nvim/
      init.lua
    vim/
      (可选：如果你希望把 vim 也迁到 ~/.config/vim)

  overlays/
    os/
      linux/
        home/
          .bashrc             # 只放 Linux 特有的增量（或直接覆盖）
        config/
          ...
      windows/
        home/
          Documents/PowerShell/Microsoft.PowerShell_profile.ps1
        config/
          # 例如：wezterm、git、ssh（在 Windows 上的路径按需要调整）
      wsl/
        home/
          .wslconfig          # 注意：.wslconfig 实际在 Windows 用户目录；这里建议只做参考/生成

    apps/
      vim/
        home/
          .vimrc
          .vim/
            autoload/
            plugin/
      nvim/
        config/
          nvim/
            init.lua
            lua/
      git/
        home/
          .gitconfig
      tmux/
        home/
          .tmux.conf

  local/                      # 不入库（.gitignore），机器私有/密钥/公司代理等
    home/
    config/

  scripts/
    setup.sh                  # 入口：探测平台 + 选择 profile + 执行链接
    setup_linux.sh
    setup_windows.ps1
    link_tree.sh              # 通用链接/备份/dry-run

  docs/
    development_plan.md
```

说明：
- `home/`、`config/` 存放 **common 默认**。
- `overlays/os/<platform>/...` 仅放平台差异（例如 Linux 的 apt 包、Windows 的 PowerShell profile）。
- `overlays/apps/<app>/...` 仅放软件差异（例如 vim vs nvim）。
- `local/` 放私有配置（代理地址、token、内网域名、公司 git email），用 `.gitignore` 排除，安装时可选择性叠加。

## 3. 分层策略（合并/覆盖规则）

建议统一合并顺序（后者覆盖前者）：

1. `home/` + `config/`（common）
2. `overlays/os/<platform>/home` + `overlays/os/<platform>/config`
3. `overlays/apps/<selected-apps>/...`（如 `vim`/`nvim`/`tmux`/`git`）
4. `local/`（可选，默认开启但必须安全：不创建不存在的敏感文件则跳过）

冲突处理：
- 默认 **覆盖**，但在安装输出里明确提示“被覆盖的来源/目标”。
- 对插件目录等大目录（例如 `~/.vim/plugged` 或 `nvim` 的插件缓存）应做 **排除或保留策略**（你现有 `setup` 对 vim 的处理就很正确）。

## 4. Windows 侧建议覆盖范围（最小可用）

先不追求“完全一致”，建议从最小可用开始：

- `PowerShell profile`：alias、PSReadLine、环境变量、代理开关、fzf 集成。
- `Git`：`.gitconfig`、`gpg/ssh`（密钥不入库）、`core.autocrlf` 策略。
- `Terminal`：Windows Terminal 配置（可选：导出 JSON），或选择 `wezterm.lua`/`alacritty.yml`。
- `Editor`：nvim（Windows 原生或 WSL 下），至少保证 `init.lua` 的路径和依赖处理清晰。

如果主要在 Windows 上用 WSL：Windows 层只做 “Terminal/字体/WSL 入口”，开发工具链更多放到 Linux(WSL) 层即可。

## 5. 迁移计划（可落地的迭代）

### Phase 0：梳理现状（1 次性）
- 盘点当前 `files/` 里每个文件的落地点与归属（common/os/app）。
- 明确你是否主要使用：`Ubuntu`、`WSL2`、`Windows 原生`、`macOS`（决定平台优先级）。

### Phase 1：引入新布局但不破坏旧安装（小步）
- 新增 `scripts/setup.sh` 作为入口，仍可调用现有 `setup`（兼容老流程）。
- 添加 `scripts/link_tree.sh`：支持把一个目录树链接到目标根目录（含备份、dry-run、排除规则）。
- 先把 **nvim** 迁移到 `config/nvim`（从 `files/nvim` 迁移，成本最低）。

### Phase 2：把 `files/` 改为“生成物”或逐步淘汰（择一）
- 方案 A（更稳）：保留 `files/` 作为最终链接目标，由 `scripts/build.sh` 从 `home/`+`config/`+`overlays/` 生成 `files/`。
- 方案 B（更清爽）：直接让安装脚本链接 `home/` 和 `config/`，不再依赖 `files/` 的特殊命名规则。

建议默认走 **方案 B**（长期维护最简单），但 Phase 1 可以先按 A 过渡。

### Phase 3：平台化（Linux + Windows）
- Linux：把 apt 安装逻辑从根 `setup` 拆到 `scripts/setup_linux.sh`（保留你现有包列表）。
- Windows：新增 `scripts/setup_windows.ps1`（可选：winget 安装清单、PowerShell profile 链接、字体提示）。
- WSL：若需要，在 `overlays/os/wsl` 放 WSL 特有的提示与补丁（例如代理、路径映射）。

### Phase 4：软件分层（vim vs nvim、重资源插件开关）
- vim/nvim：把共有的 keymap/理念抽到 `overlays/apps/editor-common`（如果你确实需要），减少重复。
- 按资源档位提供 `profile`：`minimal` / `default` / `full`（通过环境变量或参数选择），用于控制 LSP/AI/重型插件。

## 6. 验收标准（Definition of Done）

- `scripts/setup.sh` 在 Linux 上一键完成：安装依赖（可选）、链接配置、输出清单、可重复运行不破坏已有文件。
- 在 Windows（原生或 WSL）至少能完成：PowerShell profile（或 WSL 入口）、git 基础配置、nvim 可启动。
- 同一份 repo 在不同平台跑安装，不需要手动改路径（最多通过 `DOTFILES_PROFILE`/`DOTFILES_OS` 选择）。
- `local/` 私有配置不进入 git，但安装能自动检测并叠加（若存在）。
