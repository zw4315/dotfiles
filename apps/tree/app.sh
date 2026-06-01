#!/usr/bin/env bash
# =============================================================================
# App: tree
# =============================================================================
# 以树状结构显示目录内容。
# =============================================================================

APP_NAME="tree"
APP_DESC="Display directories as trees"
APP_DEPS=()

APP_BREW_FORMULA="tree"
APP_APT_PACKAGE="tree"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd tree; then
    log_info "  tree configured. Try: tree -L 2"
  fi
}
