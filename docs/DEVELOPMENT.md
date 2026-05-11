# Dotfiles 开发文档

本文档面向日常维护者，目标是让改动更快落地、跨平台更稳、复杂度可控。

## 1. 开发目标

本仓库的第一目标不是“架构完美”，而是：

1. 新机器可以一键初始化。
2. 不破坏已有 Linux 与 Windows 路径。
3. 配置可读、可回滚、可持续演进。

如果某个设计不能显著提升这三点，就暂不引入。

## 2. 快速开始

在仓库根目录执行：

  ./init.sh --list-profiles
  ./init.sh --profile personal --dry-run
  ./init.sh --profile personal

只验证某个应用：

  ./init.sh --app git --dry-run
  ./init.sh --app git

## 3. 当前目录职责

- apps/: 按应用组织的安装与配置逻辑。
- lib/: 公共函数和平台抽象。
- os/: 平台级引导与默认设置。
- profiles/: 场景化组合（只声明“需要哪些应用”）。
- docs/: 设计说明与开发规范。

建议遵循一个简单原则：

- 业务能力放 apps。
- 平台差异放 lib/<os>.sh 或 os/<os>/。
- 组合关系放 profiles。

## 4. 变更原则（强烈建议）

1. 先小改，再抽象：先把需求做通，再提炼公共层。
2. 避免多入口：同一能力尽量只有一个主要入口函数。
3. 幂等优先：重复执行不应持续追加重复内容。
4. 失败可诊断：报错要带上下文，避免静默失败。
5. 兼容优先：任何新改动都要考虑 darwin/linux/windows 的行为差异。

## 5. 添加新应用流程

以添加新应用 foo 为例：

1. 创建目录：apps/foo/
2. 新建脚本：apps/foo/app.sh
3. 按需声明包名：APP_BREW_FORMULA, APP_APT_PACKAGE, APP_WINGET_ID
4. 实现最小生命周期：安装、配置、可选收尾
5. 在目标 profile 增加 foo
6. 先 dry-run，再实跑

最小模板：

  #!/usr/bin/env bash

  APP_NAME="foo"
  APP_DESC="Foo tool"
  APP_DEPS=()

  APP_BREW_FORMULA="foo"
  APP_APT_PACKAGE="foo"

  app_install() {
    pkg_install_auto "$APP_NAME"
  }

  app_configure() {
    :
  }

  app_post_install() {
    :
  }

## 6. 平台覆盖规则

当某应用在特定平台有差异时，使用：

- apps/<app>/darwin.sh
- apps/<app>/linux.sh
- apps/<app>/windows.sh（未来）

加载顺序为基础定义后再加载平台覆盖。

注意事项：

1. 覆盖是替换，不是继承。
2. 若需保留通用逻辑，需显式复用。
3. 覆盖文件应只处理平台差异，不重复通用代码。

## 7. 常见兼容性坑

1. macOS 默认 bash 版本较老，避免依赖高版本 bash 语法。
2. GNU 与 BSD 命令参数不一致（如 ls、grep、sort）。
3. shell 配置注入时区分 bash 与 zsh 初始化语句。
4. Windows 入口如果未实现，应明确提示而非隐式失败。

## 8. 调试与验证

建议每次改动至少完成以下检查：

1. profile dry-run：

   ./init.sh --profile personal --dry-run

2. 单 app dry-run：

   ./init.sh --app <app-name> --dry-run

3. 关键路径实跑（仅在你当前平台）：

   ./init.sh --app <app-name>

4. 脚本静态检查（如果本机已安装 shellcheck）：

   shellcheck init.sh lib/*.sh apps/*/app.sh profiles/*.sh os/*/*.sh

## 9. 推荐提交流程

1. 先提交结构变更（目录/文档）。
2. 再提交行为变更（脚本逻辑）。
3. 最后提交平台专项修复（darwin/linux/windows）。

每次提交尽量只做一件事，方便回滚与 review。

## 10. 简化路线（建议）

如果你觉得工程复杂度持续上升，优先做这三件事：

1. 缩减 profile 数量：先保留 minimal 与 personal。
2. 减少 hook 复杂度：每个应用优先保证 install + configure 两步可用。
3. 文档跟随实现：删掉暂未落地的设计章节，避免文档先行造成认知负担。

短期目标是稳定一键可用；中期再追求抽象统一。

## 11. 文档维护约定

1. 任何影响执行流程的改动，同步更新本文件。
2. 新增平台或关键抽象时，补充最小示例。
3. 文档以“可执行步骤”为主，避免只描述概念。

