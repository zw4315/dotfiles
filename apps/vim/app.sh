#!/usr/bin/env bash
# =============================================================================
# App: Vim
# =============================================================================
# 传统 Vim 编辑器配置。配置文件在 home/vimrc 和 home/vim/ 中。
# =============================================================================

APP_NAME="vim"
APP_DESC="Traditional Vim editor configuration"
APP_DEPS=()

# Vim 通常是系统预装的，不需要通过包管理器安装
# APP_BREW_FORMULA="vim"
# APP_APT_PACKAGE="vim"

app_install() {
  if ! has_cmd vim; then
    log_warn "  vim not found in PATH. Install it first (e.g., brew install vim)"
    return 0
  fi
}

app_configure() {
  # 链接 vimrc
  link_home_file "$DOTFILES/home/vimrc" ".vimrc"

  # 链接 vim 配置目录
  link_file "$DOTFILES/home/vim" "$HOME/.vim"
}

app_post_install() {
  if has_cmd vim; then
    log_info "  Vim configured. Run: vim +PlugInstall"
  fi
}
