#!/usr/bin/env bash
# =============================================================================
# App: fzf
# =============================================================================
# 命令行模糊查找器。
# =============================================================================

APP_NAME="fzf"
APP_DESC="A command-line fuzzy finder"
APP_DEPS=()

APP_BREW_FORMULA="fzf"
APP_APT_PACKAGE="fzf"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd fzf; then
    log_info "  fzf configured. Try: fzf --version"
  fi
}
