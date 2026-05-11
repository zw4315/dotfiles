#!/usr/bin/env bash
# =============================================================================
# App: Neovim
# =============================================================================
# 现代 Vim 编辑器配置。配置目录在 config/nvim/，本应用只做链接。
# =============================================================================

APP_NAME="nvim"
APP_DESC="Hyperextensible Vim-based text editor"
APP_DEPS=()

APP_BREW_FORMULA="neovim"
APP_APT_PACKAGE="neovim"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  # 链接整个 nvim 配置目录（XDG 风格）
  # 注意：config/nvim/ 在仓库根目录的 config/ 下，不在 apps/nvim/config/ 下
  # 这是为了兼容现有结构
  local src="$DOTFILES/config/nvim"
  link_config_dir "$src" "nvim"
}

app_post_install() {
  if has_cmd nvim; then
    log_info "  Neovim configured. Run: nvim"
  else
    log_warn "  Neovim binary not found in PATH after install"
  fi
}
