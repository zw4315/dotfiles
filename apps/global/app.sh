#!/usr/bin/env bash
# =============================================================================
# App: GNU Global (gtags)
# =============================================================================
# 源代码标签系统，用于代码导航。
# =============================================================================

APP_NAME="global"
APP_DESC="Source code tagging system for code navigation"
APP_DEPS=()

APP_BREW_FORMULA="global"
APP_APT_PACKAGE="global"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  # 链接 GNU Global 配置目录
  local src="$DOTFILES/home/global"
  if [[ -d "$src" ]]; then
    link_home_file "$src" ".global"
  fi

  # 链接 profile.d 环境变量片段
  local profile_src="$DOTFILES/home/profile.d/gtags.sh"
  if [[ -f "$profile_src" ]]; then
    ensure_dir "$HOME/.profile.d"
    link_file "$profile_src" "$HOME/.profile.d/gtags.sh"
  fi
}

app_post_install() {
  if has_cmd gtags; then
    log_info "  global (gtags) configured. Try: gtags --version"
  fi
}
