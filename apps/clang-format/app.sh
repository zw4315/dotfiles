#!/usr/bin/env bash
# =============================================================================
# App: clang-format
# =============================================================================
# 代码格式化工具，支持 C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C#。
# =============================================================================

APP_NAME="clang-format"
APP_DESC="Code formatter for C/C++ and other languages"
APP_DEPS=()

APP_BREW_FORMULA="clang-format"
APP_APT_PACKAGE="clang-format"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd clang-format; then
    log_info "  clang-format configured. Try: clang-format --version"
  fi
}
