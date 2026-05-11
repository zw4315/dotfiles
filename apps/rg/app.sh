#!/usr/bin/env bash
# =============================================================================
# App: ripgrep (rg)
# =============================================================================
# 快速的行搜索工具，替代 grep。
# =============================================================================

APP_NAME="rg"
APP_DESC="Line-oriented search tool that recursively searches your directory"
APP_DEPS=()

APP_BREW_FORMULA="ripgrep"
APP_APT_PACKAGE="ripgrep"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd rg; then
    log_info "  rg configured. Try: rg --version"
  fi
}
