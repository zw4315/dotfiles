#!/usr/bin/env bash
# =============================================================================
# App: Universal Ctags
# =============================================================================
# 维护的 ctags 分支，支持更多语言。
# =============================================================================

APP_NAME="ctags"
APP_DESC="Universal Ctags generates an index (tag) file of language objects"
APP_DEPS=()

APP_BREW_FORMULA="universal-ctags"
APP_APT_PACKAGE="universal-ctags"

app_install() {
  # 检查是否已有 Universal Ctags
  if has_cmd ctags; then
    local version
    version="$(ctags --version 2>&1 | head -1)"
    if [[ "$version" == *"Universal Ctags"* ]]; then
      log_info "  Already installed: Universal Ctags"
      return 0
    fi
    log_warn "  Found ctags but not Universal Ctags, will install..."
  fi

  pkg_install_auto "$APP_NAME"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd ctags; then
    log_info "  ctags configured. Try: ctags --version"
  fi
}
