#!/usr/bin/env bash
# =============================================================================
# App: Git
# =============================================================================
# 跨平台共享的 Git 配置。
# =============================================================================

APP_NAME="git"
APP_DESC="Distributed version control system"
APP_DEPS=()

# 包名声明（供 pkg_install_auto 使用）
APP_BREW_FORMULA="git"
APP_APT_PACKAGE="git"

# 默认安装：使用平台包管理器
app_install() {
  # 尝试自动安装，如果失败则跳过（因为 git 通常已预装）
  pkg_install_auto "$APP_NAME" || true
}

# 配置：链接共享的 git 配置
app_configure() {
  local config_dir="$APP_DIR/config"

  link_home_file "$config_dir/gitconfig" ".gitconfig"
  link_home_file "$config_dir/gitignore_global" ".gitignore_global"
}

# 安装后：设置一些动态配置
app_post_install() {
  # 如果 nvim 已安装，设置它为默认编辑器
  if has_cmd nvim; then
    git config --global core.editor "nvim"
  fi

  # 如果 delta 已安装，配置它为 pager
  if has_cmd delta; then
    git config --global core.pager "delta"
    git config --global delta.side-by-side "true"
    git config --global delta.line-numbers "true"
  fi

  # macOS 特定：使用 Keychain 作为凭证助手
  if [[ "$DETECTED_OS" == "darwin" ]]; then
    git config --global credential.helper osxkeychain
  fi
}
